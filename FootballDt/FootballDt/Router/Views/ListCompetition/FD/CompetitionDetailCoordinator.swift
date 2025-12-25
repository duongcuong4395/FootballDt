//
//  CompetitionDetailCoordinator.swift
//  FootballDt
//
//  Created by Macbook on 25/12/25.
//

import SwiftUI
import Combine

// MARK: - Loading State
enum LoadingState: Equatable {
    case idle
    case loading
    case success
    case failure(String)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}

// MARK: - Competition Detail Coordinator
//@MainActor
class CompetitionDetailCoordinator: ObservableObject {
    @Published var loadingState: LoadingState = .idle
    @Published var progress: Double = 0.0
    
    // Dependencies
    private let leaderboardVM: LeaderboardViewModel
    private let competitionMatchesVM: CompetitionMatchesViewModel
    private let competitionsTeamsVM: CompetitionsTeamsViewModel
    private let competitionsScorersVM: CompetitionsScorersViewModel
    
    // Task management
    private var loadingTask: Task<Void, Never>?
    
    init(
        leaderboardVM: LeaderboardViewModel,
        competitionMatchesVM: CompetitionMatchesViewModel,
        competitionsTeamsVM: CompetitionsTeamsViewModel,
        competitionsScorersVM: CompetitionsScorersViewModel
    ) {
        self.leaderboardVM = leaderboardVM
        self.competitionMatchesVM = competitionMatchesVM
        self.competitionsTeamsVM = competitionsTeamsVM
        self.competitionsScorersVM = competitionsScorersVM
    }
    
    // MARK: - Main Loading Function
    func loadCompetitionData(for competition: Competition) {
        // Cancel previous loading task
        cancelLoading()
        
        loadingState = .loading
        progress = 0.0
        
        loadingTask = Task {
            do {
                try await loadAllData(for: competition)
                
                if !Task.isCancelled {
                    DispatchQueue.main.async {
                        self.loadingState = .success
                        self.progress = 1.0
                    }
                    
                }
            } catch {
                if !Task.isCancelled {
                    loadingState = .failure(error.localizedDescription)
                    print("❌ Loading failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Parallel Loading with Progress
    private func loadAllData(for competition: Competition) async throws {
        let competitionId = "\(competition.id)"
        let competitionCode = competition.code ?? ""
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            // Task 1: Leaderboard
            group.addTask { [weak self] in
                try await self?.leaderboardVM.getLeaderboard(by: competitionCode, and: nil)
                await self?.updateProgress(0.25)
            }
            
            // Task 2: Matches
            group.addTask { [weak self] in
                try await self?.competitionMatchesVM.getCompetitionMatches(by: competitionId, and: nil)
                await self?.updateProgress(0.25)
            }
            
            // Task 3: Teams
            group.addTask { [weak self] in
                try await self?.competitionsTeamsVM.getCompetitionsTeams(by: competitionCode, and: nil)
                await self?.updateProgress(0.25)
            }
            
            // Task 4: Scorers
            group.addTask { [weak self] in
                try await self?.competitionsScorersVM.getCompetitionsScorers(by: competitionCode, and: nil)
                await self?.updateProgress(0.25)
            }
            
            // Wait for all tasks and handle errors
            try await group.waitForAll()
        }
    }
    
    // MARK: - Sequential Loading (Alternative approach)
    func loadCompetitionDataSequentially(for competition: Competition, priority: [DataType]) async throws {
        cancelLoading()
        
        loadingState = .loading
        progress = 0.0
        
        let competitionId = "\(competition.id)"
        let competitionCode = competition.code ?? ""
        let progressIncrement = 1.0 / Double(priority.count)
        
        for dataType in priority {
            guard !Task.isCancelled else { return }
            
            try await loadDataType(dataType, competitionId: competitionId, competitionCode: competitionCode)
            progress += progressIncrement
        }
        
        loadingState = .success
    }
    
    private func loadDataType(_ type: DataType, competitionId: String, competitionCode: String) async throws {
        switch type {
        case .leaderboard:
            try await leaderboardVM.getLeaderboard(by: competitionCode, and: nil)
        case .matches:
            try await competitionMatchesVM.getCompetitionMatches(by: competitionId, and: nil)
        case .teams:
            try await competitionsTeamsVM.getCompetitionsTeams(by: competitionCode, and: nil)
        case .scorers:
            try await competitionsScorersVM.getCompetitionsScorers(by: competitionCode, and: nil)
        }
    }
    
    // MARK: - Helper Methods
    private func updateProgress(_ increment: Double) {
        DispatchQueue.main.async {
            self.progress += increment
        }
        
    }
    
    func cancelLoading() {
        loadingTask?.cancel()
        loadingTask = nil
    }
    
    func reset() {
        cancelLoading()
        loadingState = .idle
        progress = 0.0
    }
    
    
}

// MARK: - Data Type Enum
enum DataType {
    case leaderboard
    case matches
    case teams
    case scorers
}

// MARK: - Updated View Models (Example protocol)
protocol CompetitionDataViewModel {
    func loadData(competitionId: String, competitionCode: String) async throws
}

// MARK: - Refactored Tap Handler
extension CompetitionDetailCoordinator {
    func handleCompetitionTapped(
        _ competition: Competition,
        listCompetitionVM: ListCompetitionViewModel,
        router: FootballDtRouter
    ) {
        // 1. Set competition
        listCompetitionVM.setCompetition(competition)
        
        // 3. Load data in parallel
        loadCompetitionData(for: competition)
        
        // 2. Navigate
        router.navigationToCompetitionDetail()
    }
}

// MARK: - Loading Overlay Component
struct LoadingOverlay: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
                Text("Loading...")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    .frame(width: 200)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.9))
            )
        }
    }
}

// MARK: - Alternative: Caching Strategy
//@MainActor
class CachedCompetitionDetailCoordinator: CompetitionDetailCoordinator {
    private var cache: [Int: CachedData] = [:]
    private let cacheExpiration: TimeInterval = 300 // 5 minutes
    
    struct CachedData {
        let timestamp: Date
        let competitionId: Int
    }
    
    override func loadCompetitionData(for competition: Competition) {
        // Check cache
        if let cached = cache[competition.id],
           Date().timeIntervalSince(cached.timestamp) < cacheExpiration {
            print("✅ Using cached data for competition \(competition.id)")
            loadingState = .success
            progress = 1.0
            return
        }
        
        // Load fresh data
        super.loadCompetitionData(for: competition)
        
        // Update cache on success
        Task {
            if case .success = loadingState {
                cache[competition.id] = CachedData(
                    timestamp: Date(),
                    competitionId: competition.id
                )
            }
        }
    }
    
    func clearCache() {
        cache.removeAll()
    }
}
