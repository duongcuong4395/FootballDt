//
//  TeamDetailRouteView.swift
//  FootballDt
//
//  Created by Macbook on 28/12/25.
//

import SwiftUI

struct TeamDetailRouteView: View {
    var body: some View {
        RouteGenericView(
            headerView: TeamDetailRouteHeaderView()
            , contentView: TeamDetailRouteContentView()
            , backgroundURLLink: nil)
        .backgroundOfPage(by: .Gradient)
    }
}


struct TeamDetailRouteHeaderView: View {
    @EnvironmentObject var router: FootballDtRouter
    @EnvironmentObject var teamVM: TeamViewModel
    
    var body: some View {
        HStack {
            if case .success(data: let team) = teamVM.teamStatus {
                Button(action: {
                    backRoute()
                }, label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                })
                
                getTeamItemHeaderView(by: team)
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .themedBackgroundWithDarkMode(.header(height: 70))
    }
    
    func backRoute() {
        router.pop()
        teamVM.resetAll()
    }
    
    @ViewBuilder
    func getTeamItemHeaderView(by team: Team) -> some View {
        HStack {
            RemoteImageView(urlString: team.crest, size: 40)
            VStack(alignment: .leading) {
                Text(team.shortName ?? "")
                    .font(.body.bold())
                
            }
        }
    }
}


struct TeamDetailRouteContentView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                Text("TeamDetailRouteContentView")
            }
        }
    }
}
