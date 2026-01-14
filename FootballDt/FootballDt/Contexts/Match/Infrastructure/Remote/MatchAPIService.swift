//
//  MatchAPIService.swift
//  FootballDt
//
//  Created by Macbook on 7/1/26.
//

import Networking
import Alamofire

// MARK: Endpoint

enum MatchEndpoint<T: Decodable> {
    case fetchMatchesByCompetition(competitionID: String, season: String?)
    case fetchMatchesByTeam(teamID: Int, filters: Filters?)
    case fetchMatchesByHeadToHead(matchID: Int, filters: Filters?)
}

extension MatchEndpoint: HttpRouter {
    typealias ResponseType = T
    
    var baseURL: String { AppUtility.FootballDtBaseURL }
    
    var path: String {
        switch self {
        case .fetchMatchesByHeadToHead(let matchID, _):
            "matches/\(matchID)/head2head"
        case .fetchMatchesByTeam(teamID: let teamID, filters: _):
            "teams/\(teamID)/matches"
        case .fetchMatchesByCompetition(competitionID: let competitionID, season: _):
            "competitions/\(competitionID)/matches"
        }
    }
    
    var method: Alamofire.HTTPMethod { .get }
    
    var queryParameters: [String : Any]? {
        switch self {
        case .fetchMatchesByHeadToHead(_, let filters)
            , .fetchMatchesByTeam(teamID: _, filters: let filters):
            
            guard let filters = filters else { return nil }
            
            let params = filters.toParams()
            return params.isEmpty ? nil : params
        case .fetchMatchesByCompetition(competitionID: _, season: let season):
            guard let season = season else { return nil }
            return ["season": season]
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .fetchMatchesByHeadToHead(_, _)
            , .fetchMatchesByTeam(teamID: _, filters: _)
            , .fetchMatchesByCompetition(competitionID: _, season: _):
            return ["X-Auth-Token": AppUtility.AuthTK]
        }
    }
    
}

// MARK: APIService

class MatchAPIService: APIExecution, MatchRepository {
    func fetchMatchesByCompetition(competitionId: String, season: String?, filters: Filters?) async throws -> MatchesByCompetition {
        let response: MatchesByCompetitionAPIResponse = try await sendRequest(for: MatchEndpoint<MatchesByCompetitionAPIResponse>.fetchMatchesByCompetition(competitionID: competitionId, season: season))
        
        return response.toDomain()
    }
    
    func fetchMatchesByTeam(teamId: Int, filters: Filters?) async throws -> MatchesByTeam {
        let response: MatchesByTeamAPIResponse = try await sendRequest(for: MatchEndpoint<MatchesByTeamAPIResponse>.fetchMatchesByTeam(teamID: teamId, filters: filters))
        
        return response.toDomain()
    }
    
    func fetchMatchesByHeadToHead(matchId: Int, filters: Filters?) async throws -> MatchesByHeadToHead {
        let response: MatchesByHeadToHeadAPIResponse = try await sendRequest(for: MatchEndpoint<MatchesByHeadToHeadAPIResponse>.fetchMatchesByHeadToHead(matchID: matchId, filters: filters))
        
        return response.toDomain()
    }
}
