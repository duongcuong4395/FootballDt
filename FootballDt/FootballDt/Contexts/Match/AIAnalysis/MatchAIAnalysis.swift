//
//  MatchAIAnalysis.swift
//  FootballDt
//
//  Created by Macbook on 14/1/26.
//

import SwiftUI
import AIManageKit

protocol MatchAIAnalysis: AnyObject {
    var aiCoordinator: AIAnalysisCoordinator { get }
    // State management
    var showAnalysisView: Bool { get set }
    var selectedMatchForAnalysis: Match?  { get set }
    var matchesByHeadToHead: MatchesByHeadToHead?  { get set }
    var isLoadingEncounters: Bool  { get set }
    var showAIConfigSheet: Bool  { get set }
}

extension MatchAIAnalysis {
    func handleAnalysisRequest(for match: Match) {
        guard #available(iOS 17.0, *) else {
            showAnalysisView = true
            selectedMatchForAnalysis = match
            return
        }
        
        Task { @MainActor in
            // Step 1: Check if AI can analyze (with validation)
            let canAnalyze = await aiCoordinator.canAnalyze()
            
            if !canAnalyze {
                // Show config required
                showAIConfigSheet = true
                return
            }
            
            // Step 2: Set selected match
            selectedMatchForAnalysis = match
            
            // Step 3: Load matches By Head To Head
            loadMatchesByHeadToHead(for: match)
        }
    }
    
    private func loadMatchesByHeadToHead(for match: Match) {
        guard match.homeTeam.id != nil,
            match.awayTeam.id != nil else {
          showAnalysisView = true
          return
        }
        
        isLoadingEncounters = true
        
        Task { @MainActor in
            do {
                let matchAPIService = MatchAPIService()
                let useCase = FetchMatchesByHeadToHeadUseCase(repository: matchAPIService)
                let headToHead = try await useCase.execute(by: match.id, and: nil)
                
                print("load matchesByHeadToHead encounters.count: ", headToHead.matches?.count ?? 0)
                
                matchesByHeadToHead = headToHead
                isLoadingEncounters = false
                showAnalysisView = true
                
            } catch {
                print("Error loading matches By Head To Head: \(error)")
                
                // Continue with analysis even without encounters
                matchesByHeadToHead = nil
                isLoadingEncounters = false
                showAnalysisView = true
            }
        }
    }
    
    var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                VStack(spacing: 8) {
                    Text("Loading head-to-head history...")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    Text("Please wait...")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
        }
    }
    
    var iOSVersionWarningView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundStyle(.orange)
            
            Text("Requires iOS 17+")
                .font(.headline)
            
            Text("The AI ​​Analysis feature requires iOS 17.0 or later.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Close") {
                self.showAnalysisView = false
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(Color.blue)
            .foregroundStyle(.white)
            .cornerRadius(10)
        }
        .padding()
    }
    
    var aiToolbarMenu: some View {
        Menu {
            Button {
                self.showAIConfigSheet = true
            } label: {
                Label("AI Configuration", systemImage: "gearshape")
            }
            
            if #available(iOS 17.0, *) {
                Button {
                    Task {
                        let canAnalyze = await self.aiCoordinator.canAnalyze()
                        print("AI Status - Can Analyze: \(canAnalyze)")
                        print("Key Status: \(self.aiCoordinator.aiManager.keyStatus)")
                    }
                } label: {
                    Label("AI testing", systemImage: "checkmark.circle")
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}


class MatchAIAnalysisManager: ObservableObject, MatchAIAnalysis {
    let aiCoordinator: AIAnalysisCoordinator
    
    @Published var showAnalysisView = false
    @Published var selectedMatchForAnalysis: Match?
    @Published var matchesByHeadToHead: MatchesByHeadToHead?
    @Published var isLoadingEncounters = false
    @Published var showAIConfigSheet = false
    
    init(aiCoordinator: AIAnalysisCoordinator) {
        self.aiCoordinator = aiCoordinator
    }
}

struct AIMatchAnalysisModifier: ViewModifier {
    @StateObject private var manager: MatchAIAnalysisManager
    let onAnalysisRequest: (Match) -> Void
    
    init(coordinator: AIAnalysisCoordinator, onAnalysisRequest: @escaping (Match) -> Void) {
        _manager = StateObject(wrappedValue: MatchAIAnalysisManager(aiCoordinator: coordinator))
        self.onAnalysisRequest = onAnalysisRequest
    }
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $manager.showAnalysisView) {
                manager.selectedMatchForAnalysis = nil
                manager.matchesByHeadToHead = nil
            } content: {
                if let match = manager.selectedMatchForAnalysis {
                    if #available(iOS 17.0, *) {
                        UnifiedAnalysisView(
                            match: match,
                            matchesByHeadToHead: manager.matchesByHeadToHead,
                            coordinator: manager.aiCoordinator
                        )
                    } else {
                        manager.iOSVersionWarningView
                    }
                }
            }
            .sheet(isPresented: $manager.showAIConfigSheet) {
                if #available(iOS 17.0, *) {
                    AIConfigurationSheet(coordinator: manager.aiCoordinator)
                }
            }
            .overlay {
                if manager.isLoadingEncounters {
                    manager.loadingOverlay
                }
            }
            .toolbar {
                manager.aiToolbarMenu
            }
    }
}

// Sử dụng ViewModifier
extension View {
    func aiMatchAnalysis(
        coordinator: AIAnalysisCoordinator,
        onRequest: @escaping (Match) -> Void
    ) -> some View {
        modifier(AIMatchAnalysisModifier(coordinator: coordinator, onAnalysisRequest: onRequest))
    }
}

struct AIConfigurationSheet: View {
    @ObservedObject var coordinator: AIAnalysisCoordinator
    @State private var apiKey = ""
    @State private var showKeyInput = false
    @State private var isValidating = false
    @State private var validationMessage: String?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                // Status Section
                Section {
                    HStack {
                        Image(systemName: statusIcon)
                            .foregroundStyle(statusColor)
                        Text("Status")
                        Spacer()
                        Text(statusText)
                            .foregroundStyle(.secondary)
                    }
                    
                    if let message = validationMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(message.contains("success") ? .green : .red)
                    }
                } header: {
                    Text("AI Connection")
                }
                
                // API Key Section
                Section {
                    if coordinator.aiManager.keyStatus == .notConfigured || showKeyInput {
                        VStack(alignment: .leading, spacing: 8) {
                            SecureField("Enter Gemini API Key", text: $apiKey)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .disabled(isValidating)
                            
                            Button(action: saveAPIKey) {
                                if isValidating {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Text("Save API Key")
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .disabled(apiKey.isEmpty || isValidating)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Configured API Key")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                            
                            Button("Change API Key") {
                                showKeyInput = true
                            }
                            .foregroundStyle(.blue)
                        }
                    }
                } header: {
                    Text("API Key")
                } footer: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Get a free API Key from Google AI Studio")
                        
                        Link(destination: URL(string: "https://makersuite.google.com/app/apikey")!) {
                            HStack {
                                Image(systemName: "link")
                                Text("Open Google AI Studio")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                            }
                        }
                    }
                }
                
                // Model Selection
                Section {
                    NavigationLink {
                        AIModelPickerView(aiManager: coordinator.aiManager)
                    } label: {
                        HStack {
                            Text("Model AI")
                            Spacer()
                            Text(coordinator.aiManager.configuration.model.displayName)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Model Configuration")
                }
                
                // Test Connection
                if coordinator.aiManager.keyStatus == .valid {
                    Section {
                        Button(action: testConnection) {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                Text("Check the connection")
                                Spacer()
                                if isValidating {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                            }
                        }
                        .disabled(isValidating)
                    }
                }
            }
            .navigationTitle("AI Configuration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Properties
    
    private var statusIcon: String {
        switch coordinator.aiManager.keyStatus {
        case .valid: return "checkmark.circle.fill"
        case .invalid: return "xmark.circle.fill"
        case .validating: return "clock.fill"
        case .notConfigured: return "exclamationmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch coordinator.aiManager.keyStatus {
        case .valid: return .green
        case .invalid: return .red
        case .validating: return .orange
        case .notConfigured: return .gray
        }
    }
    
    private var statusText: String {
        switch coordinator.aiManager.keyStatus {
        case .valid: return "Connected"
        case .invalid: return "Invalid"
        case .validating: return "Verification in progress..."
        case .notConfigured: return "Not yet configured"
        }
    }
    
    // MARK: - Actions
    
    private func saveAPIKey() {
        guard !apiKey.isEmpty else { return }
        
        isValidating = true
        validationMessage = nil
        
        Task {
            do {
                try await coordinator.updateAPIKey(apiKey)
                
                await MainActor.run {
                    isValidating = false
                    validationMessage = "✓ The API Key has been successfully saved"
                    apiKey = ""
                    showKeyInput = false
                }
                
                // Auto dismiss after success
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                await MainActor.run {
                    validationMessage = nil
                }
                
            } catch {
                await MainActor.run {
                    isValidating = false
                    validationMessage = "✗ Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func testConnection() {
        isValidating = true
        validationMessage = nil
        
        Task {
            do {
                let response = try await coordinator.aiManager.sendRequest(
                    prompt: "Hello, test connection",
                    configuration: AIConfiguration(
                        maxOutputTokens: 10,
                        timeout: 10,
                        retryAttempts: 1
                    )
                )
                
                await MainActor.run {
                    isValidating = false
                    validationMessage = "✓ Connection successful: \(response.text.prefix(20))..."
                }
                
            } catch {
                await MainActor.run {
                    isValidating = false
                    validationMessage = "✗ Connection failed: \(error.localizedDescription)"
                }
            }
        }
    }
}
