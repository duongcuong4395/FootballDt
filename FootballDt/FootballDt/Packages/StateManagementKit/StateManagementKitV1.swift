//
//  StateManagementKitV1.swift
//  FootballDt
//
//  Created by Macbook on 4/1/26.
//

// MARK: Version: 1.0.0

/*
// StateManagementKit.swift
// Production-Ready State Management Package for SwiftUI
// Version: 1.0.0

import SwiftUI
import Foundation
import Combine

// MARK: ====================================================
// MARK: - 1. Core AsyncState (Support cả Array và Single Item)
// MARK: ====================================================

/// Generic async state với support cho partial updates
/// ✅ Hoạt động với cả [Model] và Model đơn
@frozen
public enum AsyncState<T> {
    case idle
    case loading(previous: T? = nil)
    case success(T)
    case failure(Error, previous: T? = nil)
    
    /// Current data regardless of state
    public var data: T? {
        switch self {
        case .idle:
            return nil
        case .loading(let previous):
            return previous
        case .success(let data):
            return data
        case .failure(_, let previous):
            return previous
        }
    }
    
    public var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    public var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
    
    public var error: Error? {
        if case .failure(let error, _) = self { return error }
        return nil
    }
}

// MARK: ====================================================
// MARK: - 1A. SingleStateStore - Cho Model đơn
// MARK: ====================================================

/// State store cho single model (không phải array)
/// ✅ Dùng khi API trả về 1 object: User, Profile, Settings...
@MainActor
public final class SingleStateStore<Model: Equatable>: ObservableObject {
    
    // MARK: - Published States
    @Published public private(set) var state: AsyncState<Model> = .idle
    @Published public private(set) var mutation: ModelMutation<Model>?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var undoStack: [ModelMutation<Model>?] = []
    private var redoStack: [ModelMutation<Model>?] = []
    private var isUndoRedoEnabled = false
    
    // MARK: - Initialization
    public init() {}
    
    // MARK: - Public API
    
    /// Set initial data
    public func setState(_ newState: AsyncState<Model>) {
        state = newState
        mutation = nil
    }
    
    /// Get current model (with mutation applied if exists)
    public var currentModel: Model? {
        guard let baseModel = state.data else { return nil }
        
        if let mutation = mutation {
            return mutation.apply(to: baseModel)
        }
        return baseModel
    }
    
    /// Update model property
    public func update<Value>(
        keyPath: WritableKeyPath<Model, Value>,
        value: Value
    ) {
        guard var model = state.data else { return }
        
        // Save for undo
        if isUndoRedoEnabled {
            undoStack.append(mutation)
            redoStack.removeAll()
        }
        
        model[keyPath: keyPath] = value
        mutation = ModelMutation(mutatedModel: model)
    }
    
    /// Batch update
    public func batchUpdate(changes: @escaping (inout Model) -> Void) {
        guard var model = state.data else { return }
        
        // Save for undo
        if isUndoRedoEnabled {
            undoStack.append(mutation)
            redoStack.removeAll()
        }
        
        changes(&model)
        mutation = ModelMutation(mutatedModel: model)
    }
    
    /// Commit mutation to base state
    public func commitMutation() {
        guard let mutatedModel = mutation?.mutatedModel else { return }
        state = .success(mutatedModel)
        mutation = nil
        
        if isUndoRedoEnabled {
            undoStack.removeAll()
            redoStack.removeAll()
        }
    }
    
    /// Discard mutation
    public func discardMutation() {
        mutation = nil
    }
    
    /// Check if has pending mutation
    public var hasMutation: Bool {
        mutation != nil
    }
    
    // MARK: - Undo/Redo
    
    public func enableUndoRedo() {
        isUndoRedoEnabled = true
    }
    
    public func disableUndoRedo() {
        isUndoRedoEnabled = false
        undoStack.removeAll()
        redoStack.removeAll()
    }
    
    public func undo() {
        guard isUndoRedoEnabled, !undoStack.isEmpty else { return }
        redoStack.append(mutation)
        mutation = undoStack.removeLast()
    }
    
    public func redo() {
        guard isUndoRedoEnabled, !redoStack.isEmpty else { return }
        undoStack.append(mutation)
        mutation = redoStack.removeLast()
    }
    
    public var canUndo: Bool {
        isUndoRedoEnabled && !undoStack.isEmpty
    }
    
    public var canRedo: Bool {
        isUndoRedoEnabled && !redoStack.isEmpty
    }
}

// MARK: ====================================================
// MARK: - 1B. SingleStateContainer - Base ViewModel cho Single Model
// MARK: ====================================================

/// Base class cho ViewModels với single model state
@MainActor
open class SingleStateContainer<Model: Equatable>: ObservableObject {
    
    @Published public var store: SingleStateStore<Model>
    
    public init() {
        self.store = SingleStateStore<Model>()
    }
    
    // MARK: - Convenience Methods
    
    public func loadData(_ loader: @escaping () async throws -> Model) async {
        store.setState(.loading(previous: store.state.data))
        
        do {
            let data = try await loader()
            store.setState(.success(data))
        } catch {
            store.setState(.failure(error, previous: store.state.data))
        }
    }
    
    public func update<Value>(
        keyPath: WritableKeyPath<Model, Value>,
        value: Value
    ) {
        store.update(keyPath: keyPath, value: value)
    }
    
    public func batchUpdate(changes: @escaping (inout Model) -> Void) {
        store.batchUpdate(changes: changes)
    }
    
    public var model: Model? {
        store.currentModel
    }
    
    public func commitChanges() {
        store.commitMutation()
    }
    
    public func discardChanges() {
        store.discardMutation()
    }
}

/// Represents a model mutation
public struct ModelMutation<Model: Equatable>: Equatable {
    let mutatedModel: Model
    
    func apply(to original: Model) -> Model {
        return mutatedModel
    }
    
    func merging(with newer: Model) -> ModelMutation<Model> {
        return ModelMutation(mutatedModel: newer)
    }
    
    public static func == (lhs: ModelMutation<Model>, rhs: ModelMutation<Model>) -> Bool {
        return lhs.mutatedModel == rhs.mutatedModel
    }
}

/// Represents an update operation - ✅ FIX: Thêm constraint Identifiable
struct ModelUpdate<Model: Identifiable> {
    let id: Model.ID
    let changes: [Change]
    
    enum Change {
        case keyPath(PartialKeyPath<Model>, Any)
        case closure((inout Model) -> Void)
    }
}

// MARK: ====================================================
// MARK: - 3. StateStore - Core State Management
// MARK: ====================================================

/// Thread-safe state store với granular updates
@MainActor
public final class StateStore<Model: Identifiable & Equatable>: ObservableObject {
    
    // MARK: - Published States
    @Published public private(set) var state: AsyncState<[Model]> = .idle
    @Published public private(set) var mutations: [Model.ID: ModelMutation<Model>] = [:]
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let updateSubject = PassthroughSubject<ModelUpdate<Model>, Never>()
    
    // ✅ FIX: Undo/Redo stacks as instance properties
    private var undoStack: [[Model.ID: ModelMutation<Model>]] = []
    private var redoStack: [[Model.ID: ModelMutation<Model>]] = []
    private var isUndoRedoEnabled = false
    
    // MARK: - Configuration
    public struct Configuration {
        var debounceInterval: TimeInterval = 0.05
        var batchUpdates: Bool = true
        
        public init(debounceInterval: TimeInterval = 0.05, batchUpdates: Bool = true) {
            self.debounceInterval = debounceInterval
            self.batchUpdates = batchUpdates
        }
    }
    
    private let config: Configuration
    
    // MARK: - Initialization
    public init(config: Configuration = .init()) {
        self.config = config
        setupUpdatePipeline()
    }
    
    // MARK: - Setup
    private func setupUpdatePipeline() {
        if config.batchUpdates {
            updateSubject
                .collect(.byTime(DispatchQueue.main, .milliseconds(Int(config.debounceInterval * 1000))))
                .sink { [weak self] updates in
                    self?.applyBatchUpdates(updates)
                }
                .store(in: &cancellables)
        } else {
            updateSubject
                .sink { [weak self] update in
                    self?.applyUpdate(update)
                }
                .store(in: &cancellables)
        }
    }
    
    // MARK: - Public API
    
    /// Set initial data
    public func setState(_ newState: AsyncState<[Model]>) {
        state = newState
        mutations.removeAll()
    }
    
    /// Get model với mutations applied
    public func model(withId id: Model.ID) -> Model? {
        guard let baseModel = baseModel(withId: id) else { return nil }
        
        if let mutation = mutations[id] {
            return mutation.apply(to: baseModel)
        }
        return baseModel
    }
    
    /// Get all models with mutations applied
    public func allModels() -> [Model] {
        guard case .success(let models) = state else { return [] }
        
        return models.map { model in
            if let mutation = mutations[model.id] {
                return mutation.apply(to: model)
            }
            return model
        }
    }
    
    /// ✅ FIX: Update single model property với type-safe casting
    public func update<Value>(
        _ id: Model.ID,
        keyPath: WritableKeyPath<Model, Value>,
        value: Value
    ) {
        let update = ModelUpdate<Model>(
            id: id,
            changes: [.keyPath(keyPath, value)]
        )
        updateSubject.send(update)
    }
    
    /// Batch update multiple properties
    public func batchUpdate(_ id: Model.ID, changes: @escaping (inout Model) -> Void) {
        let update = ModelUpdate<Model>(
            id: id,
            changes: [.closure(changes)]
        )
        updateSubject.send(update)
    }
    
    /// Commit all mutations to base state
    public func commitMutations() {
        guard case .success(var models) = state else { return }
        
        for (id, mutation) in mutations {
            if let index = models.firstIndex(where: { $0.id == id }) {
                models[index] = mutation.apply(to: models[index])
            }
        }
        
        state = .success(models)
        mutations.removeAll()
        
        // Clear undo/redo after commit
        if isUndoRedoEnabled {
            undoStack.removeAll()
            redoStack.removeAll()
        }
    }
    
    /// Discard all mutations
    public func discardMutations() {
        mutations.removeAll()
    }
    
    /// Check if model has pending mutations
    public func hasMutations(for id: Model.ID) -> Bool {
        mutations[id] != nil
    }
    
    // MARK: - Private Helpers
    
    private func baseModel(withId id: Model.ID) -> Model? {
        guard case .success(let models) = state else { return nil }
        return models.first(where: { $0.id == id })
    }
    
    /// ✅ FIX: Safe type casting for keyPath updates
    private func applyUpdate(_ update: ModelUpdate<Model>) {
        guard var baseModel = baseModel(withId: update.id) else { return }
        
        // Save current state for undo if enabled
        if isUndoRedoEnabled {
            undoStack.append(mutations)
            redoStack.removeAll() // Clear redo stack on new change
        }
        
        // Apply changes to create mutation
        for change in update.changes {
            switch change {
            case .keyPath(let keyPath, let value):
                // ✅ Safe casting
                if let writableKeyPath = keyPath as? WritableKeyPath<Model, Any> {
                    baseModel[keyPath: writableKeyPath] = value
                }
            case .closure(let transform):
                transform(&baseModel)
            }
        }
        
        // Store mutation
        if let existingMutation = mutations[update.id] {
            mutations[update.id] = existingMutation.merging(with: baseModel)
        } else {
            mutations[update.id] = ModelMutation(mutatedModel: baseModel)
        }
    }
    
    private func applyBatchUpdates(_ updates: [ModelUpdate<Model>]) {
        guard !updates.isEmpty else { return }
        
        for update in updates {
            applyUpdate(update)
        }
    }
}

// MARK: ====================================================
// MARK: - 4. StateContainer - ViewModel Base Class
// MARK: ====================================================

/// Base class cho ViewModels với built-in state management
@MainActor
open class StateContainer<Model: Identifiable & Equatable>: ObservableObject {
    
    @Published public var store: StateStore<Model>
    
    public init() {
        self.store = StateStore<Model>()
    }
    
    // MARK: - Convenience Methods
    
    public func loadData(_ loader: @escaping () async throws -> [Model]) async {
        store.setState(.loading(previous: store.state.data))
        
        do {
            let data = try await loader()
            store.setState(.success(data))
        } catch {
            store.setState(.failure(error, previous: store.state.data))
        }
    }
    
    public func updateModel<Value>(
        _ id: Model.ID,
        keyPath: WritableKeyPath<Model, Value>,
        value: Value
    ) {
        store.update(id, keyPath: keyPath, value: value)
    }
    
    public func batchUpdateModel(_ id: Model.ID, changes: @escaping (inout Model) -> Void) {
        store.batchUpdate(id, changes: changes)
    }
    
    public func model(withId id: Model.ID) -> Model? {
        store.model(withId: id)
    }
    
    public func allModels() -> [Model] {
        store.allModels()
    }
    
    public func commitChanges() {
        store.commitMutations()
    }
    
    public func discardChanges() {
        store.discardMutations()
    }
}

// MARK: ====================================================
// MARK: - 5. View Extensions
// MARK: ====================================================

public extension View {
    /// ✅ FIX: Bind to model updates with Equatable constraint
    func onModelUpdate<Model: Identifiable & Equatable>(
        _ id: Model.ID,
        in store: StateStore<Model>,
        perform action: @escaping (Model) -> Void
    ) -> some View {
        self.onChange(of: store.mutations[id]) { _ in
            if let model = store.model(withId: id) {
                action(model)
            }
        }
    }
}

// MARK: ====================================================
// MARK: - 6. Property Wrappers
// MARK: ====================================================

/// Property wrapper for observing specific model
@propertyWrapper
public struct ObservedModel<Model: Identifiable & Equatable>: DynamicProperty {
    @ObservedObject private var store: StateStore<Model>
    private let id: Model.ID
    
    public init(id: Model.ID, store: StateStore<Model>) {
        self.id = id
        self._store = ObservedObject(wrappedValue: store)
    }
    
    public var wrappedValue: Model? {
        store.model(withId: id)
    }
    
    public var projectedValue: Binding<Model?> {
        Binding(
            get: { store.model(withId: id) },
            set: { newValue in
                guard let newValue = newValue else { return }
                store.batchUpdate(id) { model in
                    model = newValue
                }
            }
        )
    }
}

// MARK: ====================================================
// MARK: - 7. Undo/Redo Support
// MARK: ====================================================

public extension StateStore {
    
    /// ✅ FIX: Instance method instead of static properties
    func enableUndoRedo() {
        isUndoRedoEnabled = true
    }
    
    func disableUndoRedo() {
        isUndoRedoEnabled = false
        undoStack.removeAll()
        redoStack.removeAll()
    }
    
    func undo() {
        guard isUndoRedoEnabled, !undoStack.isEmpty else { return }
        
        // Save current state to redo
        redoStack.append(mutations)
        
        // Restore previous state
        mutations = undoStack.removeLast()
    }
    
    func redo() {
        guard isUndoRedoEnabled, !redoStack.isEmpty else { return }
        
        // Save current state to undo
        undoStack.append(mutations)
        
        // Restore next state
        mutations = redoStack.removeLast()
    }
    
    var canUndo: Bool {
        isUndoRedoEnabled && !undoStack.isEmpty
    }
    
    var canRedo: Bool {
        isUndoRedoEnabled && !redoStack.isEmpty
    }
}

// MARK: ====================================================
// MARK: - 8. Persistence Support
// MARK: ====================================================

public protocol Persistable {
    func save() async throws
    func load() async throws
}

public extension StateStore where Model: Codable {
    
    func saveToUserDefaults(key: String) throws {
        guard case .success(let models) = state else { return }
        let data = try JSONEncoder().encode(models)
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func loadFromUserDefaults(key: String) throws {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        let models = try JSONDecoder().decode([Model].self, from: data)
        setState(.success(models))
    }
}

// MARK: ====================================================
// MARK: - 9. Filtering and Sorting
// MARK: ====================================================

public extension StateStore {
    
    func filtered(_ predicate: @escaping (Model) -> Bool) -> [Model] {
        allModels().filter(predicate)
    }
    
    func sorted(by areInIncreasingOrder: @escaping (Model, Model) -> Bool) -> [Model] {
        allModels().sorted(by: areInIncreasingOrder)
    }
}

// MARK: ====================================================
// MARK: - 10. Testing Support
// MARK: ====================================================

#if DEBUG
public extension StateStore {
    
    static func mock(with models: [Model]) -> StateStore<Model> {
        let store = StateStore<Model>()
        store.setState(.success(models))
        return store
    }
    
    func simulateUpdate(_ id: Model.ID, _ transform: @escaping (inout Model) -> Void) {
        batchUpdate(id, changes: transform)
    }
}
#endif

*/
