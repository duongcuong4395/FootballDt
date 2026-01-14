//
//  AIAnalysisCoordinator.swift
//  FootballDt
//
//  Created by Macbook on 13/1/26.
//

import Foundation
import Observation
import AIManageKit

//@available(iOS 17.0, *)
class AIAnalysisCoordinator: ObservableObject {
    
    // MARK: - Dependencies
    @Published private(set) var aiManager: AIManager
    
    // MARK: - State
    enum CoordinatorState {
        case idle
        case checkingConfiguration
        case configurationRequired(reason: String)
        case ready
        case preparingAnalysis
        case analyzing(progress: Double)
        case completed(result: AnalysisResult)
        case error(AIAnalysisError)
    }
    
    @Published private(set) var state: CoordinatorState = .idle
    @Published private(set) var streamedMarkdown: String = ""
    @Published private(set) var isStreamComplete: Bool = false
    
    // MARK: - Initialization
    init(aiManager: AIManager) {
        self.aiManager = aiManager
    }
    
    convenience init() {
        let manager = AIManager(
            useKeychain: true,
            configuration: AIConfiguration(
                model: .gemini25FlashLite,
                temperature: 0.7,
                maxOutputTokens: 4096,
                timeout: 60,
                retryAttempts: 3
            )
        )
        self.init(aiManager: manager)
    }
    
    // MARK: - Main Analysis Flow
    
    /// Match analysis with full validation
    func analyzeMatch(
        _ match: Match,
        matchesByHeadToHead: MatchesByHeadToHead? = nil
    ) async {
        // Step 1: Check Configuration
        guard await validateConfiguration() else {
            return
        }
        
        // Step 2: Prepare Analysis
        await prepareAnalysis()
        
        // Step 3: Execute Analysis với Streaming
        await executeStreamingAnalysis(match: match, matchesByHeadToHead: matchesByHeadToHead)
    }
    
    // MARK: - Configuration Validation
    
    /// Check the full AI configuration.
    private func validateConfiguration() async -> Bool {
        await setState(.checkingConfiguration)
        
        // Check 1: API Key exists
        guard await aiManager.hasValidKey() else {
            await setState(.configurationRequired(reason: "The API Key has not been configured. Please add the Gemini API Key."))
            return false
        }
        
        // Check 2: Validate API Key
        do {
            let key = try await aiManager.getAPIKey()
            
            // Check if the key is in a valid format
            if key.isEmpty || key.count < 20 {
                await setState(.configurationRequired(reason: "The API key is invalid. Please check it again."))
                return false
            }
            
            // Check 3: Key status
            if case .invalid = aiManager.keyStatus {
                await setState(.configurationRequired(reason: "The API key is invalid or has expired."))
                return false
            }
            
            // Check 4: Test connection (optional but recommended)
            if case .notConfigured = aiManager.keyStatus {
                // Try to validate by making a test request
                let testPrompt = "Hello"
                _ = try await aiManager.sendRequest(
                    prompt: testPrompt,
                    configuration: AIConfiguration(
                        maxOutputTokens: 10,
                        timeout: 10,
                        retryAttempts: 1
                    )
                )
            }
            
            await setState(.ready)
            return true
            
        } catch let error as AIError {
            let reason: String
            switch error {
            case .invalidAPIKey:
                reason = "Invalid API Key. Please check your key again."
            case .keyNotFound:
                reason = "API Key not found. Please add a new key."
            case .networkError(let message):
                reason = "Connection error: \(message)"
            case .timeout:
                reason = "Connection timed out. Please check your internet connection and try again."
            case .rateLimitExceeded:
                reason = "The request limit has been exceeded. Please try again later."
            default:
                reason = "Error: \(error.localizedDescription)"
            }
            await setState(.configurationRequired(reason: reason))
            return false
        } catch {
            await setState(.configurationRequired(reason: "Unknown error: \(error.localizedDescription)"))
            return false
        }
    }
    
    /// Can a quick check be performed to analyze it?
    func canAnalyze() async -> Bool {
        return await aiManager.hasValidKey() && aiManager.keyStatus == .valid
    }
    
    // MARK: - Prepare Analysis
    
    private func prepareAnalysis() async {
        await setState(.preparingAnalysis)
        
        // Reset state
        await MainActor.run {
            self.streamedMarkdown = ""
            self.isStreamComplete = false
        }
        
        // Small delay for UI feedback
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
    }
    
    // MARK: - Execute Streaming Analysis
    
    private func executeStreamingAnalysis(
        match: Match,
        matchesByHeadToHead: MatchesByHeadToHead?
    ) async {
        do {
            await setState(.analyzing(progress: 0.0))
            
            // Build prompt
            let prompt = buildComprehensivePrompt(
                match: match,
                matchesByHeadToHead: matchesByHeadToHead
            )
            
            // Execute streaming request
            let stream = try await aiManager.sendStreamingRequest(
                prompt: prompt,
                configuration: AIConfiguration(
                    model: aiManager.configuration.model,
                    temperature: 0.7,
                    maxOutputTokens: 4096,
                    timeout: 90,
                    retryAttempts: 3
                )
            )
            
            var totalChunks = 0
            var markdown = ""
            
            for try await chunk in stream {
                totalChunks += 1
                markdown += chunk
                
                await MainActor.run {
                    self.streamedMarkdown = markdown
                }
                
                // Update progress (estimate based on chunks)
                let progress = min(Double(totalChunks) / 100.0, 0.95)
                await setState(.analyzing(progress: progress))
            }
            
            // Complete
            await MainActor.run {
                self.isStreamComplete = true
            }
            
            let result = AnalysisResult(
                match: match,
                markdown: markdown,
                analyzedAt: Date(),
                prediction: extractPrediction(from: markdown),
                confidence: extractConfidence(from: markdown)
            )
            
            await setState(.completed(result: result))
            
        } catch let error as AIError {
            await setState(.error(.aiServiceError(error)))
        } catch {
            await setState(.error(.unknown(error.localizedDescription)))
        }
    }
    
    // MARK: - Prompt Builder
    
    private func buildComprehensivePrompt(
        match: Match,
        matchesByHeadToHead: MatchesByHeadToHead?
    ) -> String {
        var sections: [String] = []
        
        let intro: (vn: String, en: String) = ("""
                # ⚽ Phân Tích Trận Đấu Bóng Đá
                
                Bạn là chuyên gia phân tích bóng đá. Hãy phân tích chi tiết trận đấu sau và đưa ra dự đoán chính xác.
                """
        , """
        # ⚽ Football Match Analysis

        You are a football analysis expert. Analyze the following match in detail and make an accurate prediction.
        """
        )
        
        let matchInformation: (vn: String, en: String) = ( """
                    
                    ## 📋 Thông Tin Trận Đấu
                    
                    | Thông Tin | Chi Tiết |
                    |-----------|----------|
                    | **Đội Nhà** | \(match.homeTeam.name ?? "Unknown") |
                    | **Đội Khách** | \(match.awayTeam.name ?? "Unknown") |
                    | **Giải Đấu** | \(match.competition.name) |
                    | **Quốc Gia** | \(match.area.name ?? "Unknown") |
                    | **Thời Gian** | \(match.eventTime) |
                    | **Vòng Đấu** | \(match.matchday.map { "Vòng \($0)" } ?? "N/A") |
                    | **Giai Đoạn** | \(match.stage ?? "Regular") |
            """
            , """
        
        ## 📋 Match Information

        | Information | Details |
        |-----------|----------|
        | **Home Team** | \(match.homeTeam.name ?? "Unknown") |
        | **Away Team** | \(match.awayTeam.name ?? "Unknown") |
        | **Tournament** | \(match.competition.name) |
        | **Country** | \(match.area.name ?? "Unknown") |
        | **Time** | \(match.eventTime) |
        | **Round** | \(match.matchday.map { "Round \($0)" } ?? "N/A") |
        | **Stage** | \(match.stage ?? "Regular") |
        """
        )
        
        // Header
        sections.append(intro.vn)
        
        // Match Info
        sections.append(matchInformation.vn)
        
        /*
        // Current Score (if available)
        if match.status == "IN_PLAY" || match.status == "FINISHED" {
            let homeScore = match.score.fullTime?.home ?? 0
            let awayScore = match.score.fullTime?.away ?? 0
            sections.append("""
            
            ## 📊 Tỷ Số Hiện Tại
            
            **\(match.homeTeam.name ?? "") \(homeScore) - \(awayScore) \(match.awayTeam.name ?? "")**
            
            Trạng thái: **\(match.status)**
            """)
        }
        */
        
        /*
        // Odds Analysis
        if let homeOdds = match.odds.homeWin,
           let drawOdds = match.odds.draw,
           let awayOdds = match.odds.awayWin {
            sections.append("""
            
            ## 💰 Tỷ Lệ Cược & Phân Tích Xác Suất
            
            | Kết Quả | Tỷ Lệ | Xác Suất |
            |---------|-------|----------|
            | Đội nhà thắng | \(String(format: "%.2f", homeOdds)) | \(String(format: "%.1f%%", (1.0/homeOdds)*100)) |
            | Hòa | \(String(format: "%.2f", drawOdds)) | \(String(format: "%.1f%%", (1.0/drawOdds)*100)) |
            | Đội khách thắng | \(String(format: "%.2f", awayOdds)) | \(String(format: "%.1f%%", (1.0/awayOdds)*100)) |
            
            **Nhận định từ tỷ lệ cược:**
            - Đội được đánh giá cao: \(homeOdds < awayOdds ? match.homeTeam.name ?? "Nhà" : match.awayTeam.name ?? "Khách")
            - Khả năng có bàn thắng: \(drawOdds > 3.5 ? "Cao" : "Trung bình")
            """)
        }
        */
        
        // Previous Encounters
        if let encounters = matchesByHeadToHead,
           let matches = encounters.matches,
           !matches.isEmpty {
            
            let historyOfConfrontation: (vn: String, en: String) = ("""
                
                ## 📜 Lịch Sử Đối Đầu

                **\(min(matches.count, 10)) trận gần nhất:**
                """, """
            ## 📜 Head-to-Head History

            **\(min(matches.count, 10)) last matches:**
            """
            )
            
            sections.append(historyOfConfrontation.vn)
            
            var encountersList = ""
            for (index, prevMatch) in matches.prefix(10).enumerated() {
                let homeScore = prevMatch.score.fullTime.home ?? 0
                let awayScore = prevMatch.score.fullTime.away ?? 0
                let result = homeScore > awayScore ? "🏠" : (homeScore < awayScore ? "✈️" : "🤝")
                
                encountersList += """
                
                \(index + 1). **\(prevMatch.homeTeam.name ?? "") \(homeScore) - \(awayScore) \(prevMatch.awayTeam.name ?? "")** \(result)
                   - Ngày: \(prevMatch.eventTime)
                   - Giải: \(prevMatch.competition.name)
                """
            }
            sections.append(encountersList)
            
            // Aggregates
            if let agg = encounters.aggregates {
                let totalMatches = agg.numberOfMatches
                let homeWins = agg.homeTeam.wins
                let draws = agg.homeTeam.draws
                let awayWins = agg.awayTeam.wins
                
                let summaryStatistics: (vn: String, en: String) = ("""
                
                ### 📈 Thống Kê Tổng Hợp
                
                | Chỉ Số | Số Trận | Tỷ Lệ |
                |--------|---------|-------|
                | **Tổng số trận** | \(totalMatches) | 100% |
                | Đội nhà thắng | \(homeWins) | \(totalMatches > 0 ? String(format: "%.1f%%", Double(homeWins)/Double(totalMatches)*100) : "0%") |
                | Hòa | \(draws) | \(totalMatches > 0 ? String(format: "%.1f%%", Double(draws)/Double(totalMatches)*100) : "0%") |
                | Đội khách thắng | \(awayWins) | \(totalMatches > 0 ? String(format: "%.1f%%", Double(awayWins)/Double(totalMatches)*100) : "0%") |
                
                **Xu hướng lịch sử:** \(homeWins > awayWins ? "Đội nhà chiếm ưu thế" : (awayWins > homeWins ? "Đội khách chiếm ưu thế" : "Cân bằng sức mạnh"))
                """, """
                
                ### 📈 Summary Statistics

                | Index | Number of Matches | Percentage |

                |--------|---------|-------|

                | **Total Matches** | \(totalMatches) | 100% |

                | Home Wins | \(homeWins) | \(totalMatches > 0 ? String(format: "%.1f%%", Double(homeWins)/Double(totalMatches)*100) : "0%") |

                | Draws | \(draws) | \(totalMatches > 0 ? String(format: "%.1f%%", Double(draws)/Double(totalMatches)*100) : "0%") |

                | Away Wins | \(awayWins) | \(totalMatches > 0 ? String(format: "%.1f%%", Double(awayWins)/Double(totalMatches)*100) : "0%") |

                **Historical Trends:** (Home Wins > Away Wins? "Home team dominates" : (Away Wins > Home Wins? "Away team dominates" : "Equal balance of power"))
                """)
                
                sections.append(summaryStatistics.vn)
            }
        }
        
        let analysisRequest: (vn: String, en: String) = ("""
        
        ## 🎯 Yêu Cầu Phân Tích
        
        Hãy phân tích toàn diện và cung cấp:
        
        ### 1. 📊 Phân Tích Phong Độ
        - Đánh giá phong độ gần đây của cả hai đội
        - Phân tích điểm mạnh và điểm yếu
        - So sánh sức mạnh tấn công và phòng ngự
        
        ### 2. 🔍 Yếu Tố Quyết Định
        Liệt kê **5 yếu tố chính** ảnh hưởng đến kết quả:
        - Phong độ hiện tại
        - Lợi thế sân nhà/khách
        - Lịch sử đối đầu
        - Động lực thi đấu
        - Tình hình lực lượng
        
        ### 3. 🎲 Dự Đoán Chi Tiết
        
        #### Kết Quả Dự Đoán:
        - **Kết quả:** [Đội nhà thắng / Hòa / Đội khách thắng]
        - **Tỷ số dự đoán:** [X-Y]
        - **Độ tin cậy:** [Cao / Trung Bình / Thấp]
        
        #### Lý Do:
        [Giải thích chi tiết dựa trên các yếu tố phân tích]
        
        ### 4. 💡 Gợi Ý Cá Cược
        - Kèo chính: [Gợi ý]
        - Kèo phụ: [Gợi ý về tài/xỉu, handicap]
        - Mức độ rủi ro: [Thấp/Trung Bình/Cao]
        
        ### 5. ⚠️ Rủi Ro & Biến Số
        - Các yếu tố bất ngờ có thể xảy ra
        - Kịch bản thay thế
        
        ---
        
        **Lưu ý:** Hãy trả lời bằng tiếng Việt, sử dụng markdown formatting đẹp mắt với emoji phù hợp.
        """, """
        
        ## 🎯 Analysis Requirements

        Please conduct a comprehensive analysis and provide:

        ### 1. 📊 Form Analysis
        - Assess the recent form of both teams
        - Analyze strengths and weaknesses
        - Compare attacking and defensive capabilities

        ### 2. 🔍 Decisive Factors
        List **5 key factors** influencing the outcome:
        - Current form
        - Home/Away advantage
        - Head-to-head history
        - Motivation
        - Team strength

        ### 3. 🎲 Detailed Prediction
        #### Predicted Result:
        - **Result:** [Win at Home / Draw / Win Away]
        - **Predicted Score:** [X-Y]
        - **Reliability:** [High / Medium / Low]

        #### Reason:
        [Detailed explanation based on the analyzed factors]

        ### 4. 💡 Betting Suggestions
        - Main Bet: [Suggestion]
        - Side Bets: [Over/Under, Handicap Suggestion]
        - Risk Level: [Low/Medium/High]

        ### 5. ⚠️ Risks & Variables
        - Potential Unexpected Events
        - Alternative Scenarios

        ---

        **Note:** Please answer in Vietnamese, using neat markdown formatting with appropriate emojis.
        """)
        
        // Analysis Request
        sections.append(analysisRequest.vn)
        
        return sections.joined(separator: "\n")
    }
    
    // MARK: - Parsing Helpers
    
    private func extractPrediction(from markdown: String) -> MatchPrediction? {
        let lowercased = markdown.lowercased()
        
        // Try to find score prediction
        let patterns = [
            #"tỷ\s*số\s*dự\s*đoán[:\s]*(\d+)\s*[-–]\s*(\d+)"#,
            #"dự\s*đoán[:\s]*(\d+)\s*[-–]\s*(\d+)"#,
            #"kết\s*quả[:\s]*(\d+)\s*[-–]\s*(\d+)"#
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
               let match = regex.firstMatch(in: markdown, range: NSRange(markdown.startIndex..., in: markdown)),
               let homeRange = Range(match.range(at: 1), in: markdown),
               let awayRange = Range(match.range(at: 2), in: markdown) {
                let homeScore = Int(markdown[homeRange]) ?? 0
                let awayScore = Int(markdown[awayRange]) ?? 0
                
                let outcome: MatchOutcome
                if homeScore > awayScore {
                    outcome = .homeWin
                } else if homeScore < awayScore {
                    outcome = .awayWin
                } else {
                    outcome = .draw
                }
                
                return MatchPrediction(
                    outcome: outcome,
                    predictedScore: (home: homeScore, away: awayScore)
                )
            }
        }
        
        // Fallback: determine from text
        if lowercased.contains("đội nhà thắng") || lowercased.contains("chiến thắng của đội nhà") {
            return MatchPrediction(outcome: .homeWin, predictedScore: nil)
        } else if lowercased.contains("đội khách thắng") || lowercased.contains("chiến thắng của đội khách") {
            return MatchPrediction(outcome: .awayWin, predictedScore: nil)
        } else if lowercased.contains("hòa") || lowercased.contains("hai đội hòa") {
            return MatchPrediction(outcome: .draw, predictedScore: nil)
        }
        
        return nil
    }
    
    private func extractConfidence(from markdown: String) -> ConfidenceLevel {
        let lowercased = markdown.lowercased()
        
        if lowercased.contains("độ tin cậy: cao") ||
           lowercased.contains("độ tin cậy cao") ||
           lowercased.contains("tin cậy: cao") {
            return .high
        } else if lowercased.contains("độ tin cậy: thấp") ||
                  lowercased.contains("độ tin cậy thấp") ||
                  lowercased.contains("tin cậy: thấp") {
            return .low
        }
        
        return .medium
    }
    
    // MARK: - State Management
    
    private func setState(_ newState: CoordinatorState) async {
        await MainActor.run {
            self.state = newState
        }
    }
    
    // MARK: - Reset
    
    func reset() {
        state = .idle
        streamedMarkdown = ""
        isStreamComplete = false
    }
    
    // MARK: - Configuration Management
    
    func updateAPIKey(_ key: String) async throws {
        try await aiManager.setAPIKey(key)
    }
    
    func switchModel(_ model: AIModelType) {
        aiManager.switchModel(model)
    }
}

// MARK: - Supporting Types

struct AnalysisResult {
    let match: Match
    let markdown: String
    let analyzedAt: Date
    let prediction: MatchPrediction?
    let confidence: ConfidenceLevel
}

struct MatchPrediction {
    let outcome: MatchOutcome
    let predictedScore: (home: Int, away: Int)?
}

enum MatchOutcome: String {
    case homeWin = "Đội nhà thắng"
    case draw = "Hòa"
    case awayWin = "Đội khách thắng"
    case uncertain = "Chưa Rõ"
    
    var emoji: String {
        switch self {
        case .homeWin: return "🏠"
        case .draw: return "🤝"
        case .awayWin: return "✈️"
        case .uncertain: return "❓"
        }
    }
    
    var color: String {
        switch self {
        case .homeWin: return "blue"
        case .draw: return "gray"
        case .awayWin: return "red"
        case .uncertain: return "orange"
        }
    }
}

enum ConfidenceLevel: String {
    case high = "Cao"
    case medium = "Trung Bình"
    case low = "Thấp"
    
    var emoji: String {
        switch self {
        case .high: return "🎯"
        case .medium: return "🎲"
        case .low: return "❓"
        }
    }
}

enum AIAnalysisError: LocalizedError {
    case configurationRequired(String)
    case aiServiceError(AIError)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .configurationRequired(let reason):
            return reason
        case .aiServiceError(let error):
            return error.localizedDescription
        case .unknown(let message):
            return message
        }
    }
}
