//
//  TeamGeneralView.swift
//  FootballDt
//
//  Created by Macbook on 29/12/25.
//

import SwiftUI

struct TeamGeneralView: View {
    var team: Team
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 0) {
                    TeamInforView
                    if let coach = team.coach {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "person.bust")
                                Text("Coach:")
                            }
                            .font(.body.bold())
                            
                            CoachView(coach: coach)
                                .padding(0)
                            Spacer()
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    
                    Text("Running competitions:")
                        .font(.body.bold())
                    if let runningCompetitions = team.runningCompetitions {
                        HStack(spacing: 30) {
                            ForEach(runningCompetitions, id: \.id) { competition in
                                VStack {
                                    RemoteImageView(urlString: competition.emblem ?? "", size: 50)
                                }
                            }
                        }
                        .padding(0)
                    }
                }
                
                Section {
                    Text("Squad:")
                        .font(.body.bold())
                    
                    ListSquadView(listSquad: team.squad ?? [])
                        .padding(0)
                }
                
            }
        }
        .padding(10)
        
    }
    
    var TeamInforView: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                if let area = team.area {
                    AreaItemView(area: area, showName: false, imageSize: 20)
                }
                Text(team.area?.name ?? "" + "(\(team.founded ?? 0))")
                    .font(.body.bold())
                Spacer()
            }
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .font(.caption2)
                Text(team.address ?? "")
                    .font(.caption2)
            }
            .padding(0)
            
            HStack {
                Image(systemName: "sportscourt")
                    .font(.caption2)
                Text(team.venue ?? "")
                    .font(.caption2)
            }
            .padding(0)
            
            
        }
    }
}


struct ListSquadView: View {
    var listSquad: [Squad]
    
    var columns: [GridItem] = [GridItem(), GridItem()]
    var body: some View {
        
        LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
            ForEach(listSquad, id: \.id) { squad in
                squadView(squad: squad)
            }
        }
        .padding(0)
        .onAppear{
            let positions = listSquad.map { $0.position ?? "" }
            print("positions", Array(Set(positions)))
            
             /*
              ["Defence"
              , "Goalkeeper"
              , "Midfield"
              , "Centre-Forward"
              , "Right Winger"
              , "Centre-Back"
              , "Defensive Midfield"
              , "Attacking Midfield"
              , "Right-Back"
              , "Offence"
              , "Central Midfield"
              , "Left Winger"
              , "Left-Back"]
              */
        }
    }
}

struct squadView: View {
    var squad: Squad
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                Text(squad.name ?? "")
                    .font(.caption.bold())
            }
            
            HStack {
                Image(systemName: "birthday.cake")
                Text(squad.nationality ?? "")
                + Text(" (\(DateParser.convert(squad.dateOfBirth ?? "", to: "dd/MM/yyyy")))")
            }
            .font(.caption2)
            
            HStack {
                Image(systemName: "figure.arms.open")
                Text(squad.position ?? "")
            }
            .font(.caption2)
            
        }
        .padding(0)
    }
}


struct CoachView: View {
    var coach: Coach
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(coach.name ?? "")
                .font(.caption.bold())
            + Text("(\(DateParser.convert(coach.dateOfBirth ?? "", to: "dd/MM/yyyy")))")
                .font(.caption2)
            
            HStack {
                Image(systemName: "map")
                    .font(.caption2)
                Text(coach.nationality ?? "")
                    .font(.caption2)
            }
            HStack {
                Image(systemName: "pencil.and.list.clipboard")
                    .font(.caption2)
                Text("\(DateParser.convert(coach.contract?.start ?? "", to: "MM/yyyy")) - \(DateParser.convert(coach.contract?.until ?? "", to: "MM/yyyy"))")
                    .font(.caption2)
            }
        }
        
    }
}
