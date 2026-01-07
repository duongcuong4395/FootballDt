//
//  MatchDetailRouteView.swift
//  FootballDt
//
//  Created by Macbook on 6/1/26.
//

import SwiftUI

struct MatchDetailRouteView: View {
    var body: some View {
        
        
        RouteGenericView(
            headerView: MatchDetailRouteHeaderView()
            , contentView: MatchDetailRouteContentView()
            , backgroundURLLink: nil)
        .backgroundOfPage(by: .Gradient)
    }
}

struct MatchDetailRouteHeaderView: View {
    @EnvironmentObject var router: FootballDtRouter
    @EnvironmentObject var matchDetailVM: MatchDetailViewModel
    @Environment(\.colorScheme) var colorScheme
    
    
    var body: some View {
        
        HStack {
            Button(action: {
                backRoute()
            }, label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
            })
            
            if case .success(let match) = matchDetailVM.state {
                UniversalMatchItemView.header(match: match)
                //MatchItemHeaderView(match: match)
                    .scaleEffect(0.95)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .themedBackground(.header(tintColor: .backgroundColor(for: colorScheme), height: 70))
    }
    
    func backRoute() {
        router.pop()
    }
}


struct MatchDetailRouteContentView: View {
    
    @EnvironmentObject var matchDetailVM: MatchDetailViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var previousEncountersVM: PreviousEncountersViewModel
    
    init() {
        lazy var matchAPIService = MatchAPIService()
        lazy var getPreviousEncountersUC = GetPreviousEncountersUseCase(repository: matchAPIService)
        self._previousEncountersVM = StateObject(wrappedValue: PreviousEncountersViewModel(getPreviousEncountersUC: getPreviousEncountersUC))
    }
    
    var body: some View {
        VStack {
            
            //PreviousEncountersView()
            MatchesByPreviousEncountersView()
        }
        .padding(10)
        .themedBackground(.card(tintColor: .backgroundColor(for: colorScheme), cornerRadius: 20, material: .none))
        .environmentObject(previousEncountersVM)
        
    }
}
