//
//  ListCompetitionRouteView.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct ListCompetitionRouteView: View {
    @EnvironmentObject var listCompetitionVM: ListCompetitionViewModel
    @EnvironmentObject var footballDtRouter: FootballDtRouter
    @EnvironmentObject var leaderboardVM: LeaderboardViewModel
    
    var columns: [GridItem] = [GridItem(), GridItem()]
    
    var body: some View {
        VStack {
            switch listCompetitionVM.listCompetitionStatus {
            case .success(data: let competitions):
                ScrollView(showsIndicators: false) {
                    SmartGrid(columns: DeviceSize.current.isPad ? 5 : 2, spacing: .medium) {
                        ListCompetitionView(listCompetition: competitions, tappedCompetition: tappedCompetition)
                    }
                }
            case .loading:
                ProgressView()
            default:
                EmptyView()
            }
        }
        .onAppear{
            Task {
                await listCompetitionVM.getAllCompetition()
            }
        }
    }
    
    func tappedCompetition(_ competition: Competition) {
        
        listCompetitionVM.setCompetition(competition)
        footballDtRouter.navigationToCompetitionDetail()
        Task {
            await leaderboardVM.getLeaderboard(by: competition.code ?? "", and: nil)
        }
        
    }
    
}

struct ListCompetitionView: View {
    var listCompetition: [Competition]
    var tappedCompetition: (Competition) -> Void
    var body: some View {
        ForEach(listCompetition, id: \.id) { competition in
            CompetitionItemView(competition: competition)
                .padding(0)
                //.modifier(RotateOnAppearModifier(angle: -60, duration: 1, direction: .leftToRight))
                .onTapGesture {
                    tappedCompetition(competition)
                }
        }
    }
}

struct CompetitionItemView: View {
    var competition: Competition
    var isHStack: Bool = false
    
    var body: some View {
        if isHStack {
            HStack { contentView }
        } else {
            VStack { contentView }
        }
    }
    
    @ViewBuilder
    var contentView: some View {
        if let flagUrl = competition.emblem, !flagUrl.isEmpty {
            WebImage(url: URL(string: flagUrl))
                .resizable()
                .font(.caption)
                .shadow(color: Color.blue, radius: 5, x: 0, y: 0)
                .frame(width: 50, height: 50)
        } else {
            Image(systemName: "flag.slash.fill")
                .resizable()
                .foregroundColor(.secondary)
                .font(.caption)
                .shadow(color: Color.blue, radius: 5, x: 0, y: 0)
                .frame(width: 50, height: 50)
        }
        
        Text(competition.name)
            .font(.caption)
        HStack {
            if let area = competition.area {
                AreaItemView(area: area
                             , axisHStack: true
                             , showName: false, imageSize: 15)
            }
            
            Text("\(competition.currentSeason?.years ?? "")")
                .font(.caption2)
        }
    }
}


struct AreaItemView: View {
    let area: Area
    
    var axisHStack: Bool = false
    var showName: Bool = true
    var imageSize: CGFloat = 50
    
    var body: some View {
         
        if axisHStack {
            HStack {
                itemView
            }
        } else {
            VStack {
                itemView
            }
        }
    }
    
    @ViewBuilder
    var itemView: some View {
        if let flagUrl = area.flag, !flagUrl.isEmpty {
            WebImage(url: URL(string: area.flag ?? ""))
                .resizable()
                .font(.caption)
                .shadow(color: Color.blue, radius: 5, x: 0, y: 0)
                .frame(width: imageSize, height: imageSize)
        } else {
            Image(systemName: "flag.slash.fill")
                .resizable()
                .foregroundColor(.secondary)
                .font(.caption)
                .shadow(color: Color.blue, radius: 5, x: 0, y: 0)
                .frame(width: imageSize, height: imageSize)
        }
        
        if showName {
            Text(area.name)
                .font(.caption)
        }
    }
}
