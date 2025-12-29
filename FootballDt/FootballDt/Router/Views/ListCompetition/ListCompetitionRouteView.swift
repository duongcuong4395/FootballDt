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
    }
    
    func tappedCompetition(_ competition: Competition) {
        listCompetitionVM.setCompetition(competition)
        footballDtRouter.navigationToCompetitionDetail()
    }
    
    
}


struct ListCompetitionView: View {
    @EnvironmentObject var listCompetitionVM: ListCompetitionViewModel
    var listCompetition: [Competition]
    var tappedCompetition: (Competition) -> Void
    
    var body: some View {
        ForEach(listCompetition, id: \.id) { competition in
            CompetitionItemView(competition: competition, imageSize: 100)
                .padding(0)
                //.modifier(RotateOnAppearModifier_New(angle: -60, duration: 1, direction: .leftToRight))
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        tappedCompetition(competition)
                                    }
                    //tappedCompetition(competition)
                }
                
        }
    }
}

struct CompetitionItemView: View {
    var competition: Competition
    var imageSize: CGFloat = 50
    
    var isCompact: Bool = false
    
    
    var body: some View {
        if isCompact {
            HStack {
                if let flagUrl = competition.emblem, !flagUrl.isEmpty {
                    RemoteImageView(urlString: flagUrl, size: 40)
                        .shadow(color: Color.blue, radius: 5, x: 0, y: 0)
                        .transition(.scale.combined(with: .opacity))
                }
                Text(competition.name)
                    .font(.body.bold())
                    .transition(.opacity.combined(with: .move(edge: .leading)))
                
                Spacer()
            }
        } else {
            VStack {
                if let flagUrl = competition.emblem, !flagUrl.isEmpty {
                    RemoteImageView(urlString: flagUrl, size: imageSize)
                        .shadow(color: Color.blue, radius: 5, x: 0, y: 0)
                        .transition(.scale.combined(with: .opacity))
                }
                
                Text(competition.name)
                    .font(.caption.bold())
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
            RemoteImageView(urlString: area.flag, size: imageSize)
                .font(.caption)
                .shadow(color: Color.blue, radius: 5, x: 0, y: 0)
        } else {
            Image(systemName: "flag.slash.fill")
                .resizable()
                .foregroundColor(.secondary)
                .font(.caption)
                .shadow(color: Color.blue, radius: 5, x: 0, y: 0)
                .frame(width: imageSize, height: imageSize)
        }
        
        if showName {
            Text(area.name ?? "")
                .font(.caption)
        }
    }
}
