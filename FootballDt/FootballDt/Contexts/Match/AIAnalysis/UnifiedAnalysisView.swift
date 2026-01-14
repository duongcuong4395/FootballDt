//
//  UnifiedAnalysisView.swift
//  FootballDt
//
//  Created by Macbook on 13/1/26.
//

import SwiftUI
import MarkdownTypingKit

//@available(iOS 17.0, *)
/// View with complete integration of AIManageKit + MarkdownTypingKit
struct UnifiedAnalysisView: View {
    let match: Match
    let matchesByHeadToHead: MatchesByHeadToHead?
    
    @StateObject private var coordinator: AIAnalysisCoordinator
    @Environment(\.dismiss) var dismiss
    
    init(match: Match, matchesByHeadToHead: MatchesByHeadToHead?, coordinator: AIAnalysisCoordinator? = nil) {
        self.match = match
        self.matchesByHeadToHead = matchesByHeadToHead
        
        if let coordinator = coordinator {
            _coordinator = StateObject(wrappedValue: coordinator)
        } else {
            _coordinator = StateObject(wrappedValue: AIAnalysisCoordinator())
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                // Content based on state
                contentView
            }
            .navigationTitle("AI Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    if case .analyzing = coordinator.state {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
            }
        }
        .onAppear {
            startAnalysis()
        }
    }
    
    // MARK: - Content View
    
    @ViewBuilder
    private var contentView: some View {
        switch coordinator.state {
        case .idle, .checkingConfiguration:
            checkingView
            
        case .configurationRequired(let reason):
            configurationRequiredView(reason: reason)
            
        case .ready, .preparingAnalysis:
            preparingView
            
        case .analyzing(let progress):
            analyzingView(progress: progress)
            
        case .completed(let result):
            completedView(result: result)
            
        case .error(let error):
            errorView(error: error)
        }
    }
    
    // MARK: - Checking View
    
    private var checkingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
            
            VStack(spacing: 8) {
                Text("Checking the configuration...")
                    .font(.headline)
                
                Text("Authenticate API Key and establish connection")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Configuration Required View
    
    private func configurationRequiredView(reason: String) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Icon
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.orange)
                    .padding(.top, 40)
                
                // Title
                Text("Required AI Configuration")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Reason
                Text(reason)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // Configuration Card
                VStack(alignment: .leading, spacing: 16) {
                    Label("Configuration guide", systemImage: "info.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        configStep(number: 1, text: "Access Google AI Studio")
                        configStep(number: 2, text: "Generate a free API Key")
                        configStep(number: 3, text: "Copy and paste into the application")
                    }
                    
                    Link(destination: URL(string: "https://makersuite.google.com/app/apikey")!) {
                        HStack {
                            Image(systemName: "link")
                            Text("Open Google AI Studio")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        // Navigate to settings
                        showConfigurationSheet()
                    }) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                            Text("Configure Now")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        startAnalysis()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Check Again")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .foregroundStyle(.blue)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
    
    private func configStep(number: Int, text: String) -> some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
    
    // MARK: - Preparing View
    
    private var preparingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
            
            VStack(spacing: 8) {
                Text("In progress, analysis is being prepared...")
                    .font(.headline)
                
                Text("Collect data and build a prompt")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Analyzing View (với Streaming + Markdown Typing)
    
    private func analyzingView(progress: Double) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Match Info Card
                matchInfoCard
                
                // Progress Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundStyle(.blue)
                        Text("AI is Analyzing")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .tint(.blue)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                
                // Streaming Markdown Display with MarkdownTypingKit
                if !coordinator.streamedMarkdown.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundStyle(.green)
                            Text("Analysis Results")
                                .font(.headline)
                            Spacer()
                            if !coordinator.isStreamComplete {
                                ProgressView()
                                    .scaleEffect(0.7)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                        
                        // MarkdownTypewriterView from MarkdownTypingKit
                        MarkdownTypewriterView(
                            text: Binding(
                                get: { coordinator.streamedMarkdown },
                                set: { _ in }
                            ),
                            isTypingComplete: Binding(
                                get: { coordinator.isStreamComplete },
                                set: { _ in }
                            ),
                            configuration: MarkdownConfiguration(
                                typingSpeed: .fast,
                                showIndicators: false,
                                enableAutoScroll: true,
                                theme: MarkdownTheme(
                                    h1FontSize: 20,
                                    h2FontSize: 18,
                                    h3FontSize: 16,
                                    bodyFontSize: 15,
                                    codeFontSize: 13,
                                    lineSpacing: 3,
                                    sectionSpacing: 8,
                                    primaryColor: .primary,
                                    secondaryColor: .secondary,
                                    codeBackgroundColor: Color(.secondarySystemGroupedBackground),
                                    linkColor: .blue
                                )
                            )
                        )
                        .frame(minHeight: 200)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Completed View
    
    private func completedView(result: AnalysisResult) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Match Info
                matchInfoCard
                
                // Quick Prediction Card (if available)
                if let prediction = result.prediction {
                    predictionCard(prediction: prediction, confidence: result.confidence)
                }
                
                // Full Analysis with Markdown
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "doc.richtext.fill")
                            .foregroundStyle(.blue)
                        Text("Detailed Analysis")
                            .font(.headline)
                        Spacer()
                        Text(formatDate(result.analyzedAt))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Display completed markdown (no typing effect)
                    MarkdownTypewriterView(
                        text: .constant(result.markdown),
                        isTypingComplete: .constant(true),
                        configuration: MarkdownConfiguration(
                            typingSpeed: .veryFast,
                            showIndicators: false,
                            enableAutoScroll: false,
                            theme: .default
                        )
                    )
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: shareAnalysis) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .foregroundStyle(.blue)
                            .cornerRadius(10)
                    }
                    
                    Button(action: startAnalysis) {
                        Label("Re-analyze", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Error View
    
    private func errorView(error: AIAnalysisError) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.octagon.fill")
                .font(.system(size: 60))
                .foregroundStyle(.red)
            
            VStack(spacing: 8) {
                Text("Phân Tích Thất Bại")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(error.localizedDescription ?? "An unknown error has occurred")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            VStack(spacing: 12) {
                Button(action: startAnalysis) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Retry")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                }
                
                if case .configurationRequired = error {
                    Button(action: showConfigurationSheet) {
                        HStack {
                            Image(systemName: "gearshape")
                            Text("Configuration")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .foregroundStyle(.blue)
                        .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Components
    
    private var matchInfoCard: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(match.competition.name ?? "Unknown")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(match.eventTime)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(match.status.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(match.status.rawValue))
                    .foregroundStyle(.white)
                    .cornerRadius(6)
            }
            
            Divider()
            
            // Teams
            HStack(spacing: 20) {
                // Home Team
                VStack(spacing: 8) {
                    AsyncImage(url: URL(string: match.homeTeam.crest ?? "")) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Image(systemName: "shield.fill")
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 50, height: 50)
                    
                    Text(match.homeTeam.name ?? "")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity)
                
                // VS
                VStack(spacing: 4) {
                    Text("VS")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    
                    if let matchday = match.matchday {
                        Text("Round \(matchday)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                
                // Away Team
                VStack(spacing: 8) {
                    AsyncImage(url: URL(string: match.awayTeam.crest ?? "")) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Image(systemName: "shield.fill")
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 50, height: 50)
                    
                    Text(match.awayTeam.name ?? "")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func predictionCard(prediction: MatchPrediction, confidence: ConfidenceLevel) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                Text("Forecast")
                    .font(.headline)
            }
            
            HStack(spacing: 16) {
                Text(prediction.outcome.emoji)
                    .font(.system(size: 50))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(prediction.outcome.rawValue)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    if let score = prediction.predictedScore {
                        Text("\(score.home) - \(score.away)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                    }
                    
                    HStack(spacing: 4) {
                        Text(confidence.emoji)
                        Text("Reliability: \(confidence.rawValue)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
    }
    
    // MARK: - Actions
    
    private func startAnalysis() {
        Task {
            await coordinator.analyzeMatch(match, matchesByHeadToHead: matchesByHeadToHead)
        }
    }
    
    private func showConfigurationSheet() {
        // TODO: Show configuration sheet
        // You can present AIConfigurationView here
    }
    
    private func shareAnalysis() {
        // TODO: Implement share functionality
    }
    
    // MARK: - Helpers
    
    private func statusColor(_ status: String) -> Color {
        switch status {
        case "SCHEDULED", "TIMED": return .blue
        case "IN_PLAY": return .green
        case "FINISHED": return .gray
        default: return .orange
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "vi_VN")
        return formatter.string(from: date)
    }
}
