//
//  ModelsStatus.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI

enum ModelsStatus<T> {
    case idle
    case loading
    case success(data: T)
    case failure(error: String)
}

extension ModelsStatus {
    // MARK: - Computed Properties
    var data: T? {
        if case .success(let data) = self {
            return data
        }
        return nil
    }
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
    
    var error: String? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
    
    var isEmpty: Bool {
        guard let data = data as? any Collection else { return true }
        return data.isEmpty
    }
}

extension ModelsStatus where T: RangeReplaceableCollection {
    // Map operation while preserving status
    func map<U>(_ transform: (T.Element) -> U) -> ModelsStatus<[U]> {
        switch self {
        case .idle:
            return .idle
        case .loading:
            return .loading
        case .success(let data):
            let mappedData = data.map(transform)
            return .success(data: Array(mappedData))
        case .failure(let error):
            return .failure(error: error)
        }
    }
    
    // Filter operation while preserving status
    func filter(_ predicate: (T.Element) -> Bool) -> ModelsStatus<T> {
        switch self {
        case .idle:
            return .idle
        case .loading:
            return .loading
        case .success(let data):
            let filteredData = T(data.filter(predicate))
            return .success(data: filteredData)
        case .failure(let error):
            return .failure(error: error)
        }
    }
    
    // Update element
    func updateElement(where predicate: (T.Element) -> Bool,
                      with newElement: T.Element) -> ModelsStatus<T> {
        switch self {
        case .success(var data):
            if let index = data.firstIndex(where: predicate) {
                data.remove(at: index)
                data.insert(newElement, at: index)
            }
            return .success(data: data)
        default:
            return self
        }
    }
    
    // Remove element
    func removeElement(where predicate: (T.Element) -> Bool) -> ModelsStatus<T> {
        switch self {
        case .success(let data):
            let newData = T(data.filter { !predicate($0) })
            return .success(data: newData)
        default:
            return self
        }
    }
    
    // Add element
    func addElement(_ element: T.Element) -> ModelsStatus<T> {
        switch self {
        case .success(var data):
            data.append(element)
            return .success(data: data)
        default:
            return self
        }
    }
}
