//
//  TeamViewModel.swift
//  FootballDt
//
//  Created by Macbook on 28/12/25.
//

import SwiftUI

class TeamViewModel: ObservableObject {
    @Published var teamStatus: ModelsStatus<Team> = .idle
    
    private var getTeamDetailUserCase: GetTeamDetailUserCase
    
    init(getTeamDetailUserCase: GetTeamDetailUserCase) {
        self.getTeamDetailUserCase = getTeamDetailUserCase
    }
    
    func getTeamDetail(by teamID: Int) async {
        DispatchQueue.main.async {
            self.teamStatus = .loading
        }
        do {
            
            
            let team = try await getTeamDetailUserCase.execute(by: teamID)
            DispatchQueue.main.async {
                self.teamStatus = .success(data: team)
            }
        } catch {
            DispatchQueue.main.async {
                self.teamStatus = .failure(error: error.localizedDescription)
            }
        }
    }
    
    func setTeam(by team: Team) {
        teamStatus = .success(data: team)
    }
    
    func resetAll() {
        teamStatus = .idle
    }
}

class MatchesByTeamViewModel: ObservableObject {
    @Published var matchesByTeamStatus: ModelsStatus<MatchesByTeam> = .idle
    
    private var getMatchesByTeamUserCase: GetMatchesByTeamUserCase
    
    init(getMatchesByTeamUserCase: GetMatchesByTeamUserCase) {
        self.getMatchesByTeamUserCase = getMatchesByTeamUserCase
    }
    
    func getMatchesByTeam(by teamID: Int, and filters: Filters?) async {
        DispatchQueue.main.async {
            self.matchesByTeamStatus = .idle
        }
        do {
            let data = try await getMatchesByTeamUserCase.execute(by: teamID, and: filters)
            DispatchQueue.main.async {
                
                self.matchesByTeamStatus = .success(data: data)
            }
        } catch {
            DispatchQueue.main.async {
                self.matchesByTeamStatus = .failure(error: error.localizedDescription)
            }
        }
    }
    
    func resetAll() {
        self.matchesByTeamStatus = .idle
    }
    
}


extension Array where Element == Match {

    func groupedByCompetition() -> [MatchByCompetition] {
        Dictionary(grouping: self, by: { $0.competition.id })
            .compactMap { _, matches in
                guard let competition = matches.first?.competition else {
                    return nil
                }

                return MatchByCompetition(
                    competition: competition,
                    matches: matches
                )
            }
            .sorted { $0.competition.name < $1.competition.name }
    }
}
