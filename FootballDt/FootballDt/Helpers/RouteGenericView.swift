//
//  RouteGenericView.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI

struct RouteGenericView<HeaderView: View, ContentView: View>: View {
    
    private var headerView: HeaderView
    private var contentView: ContentView
    
    private var backgroundURLLink: String?
    
    init(
        headerView: HeaderView
        , contentView: ContentView
        , backgroundURLLink: String? = nil
        //, menuContent: (menu: MenuContent, animationName: String)? = nil
    ) {
            
        self.headerView = headerView
        self.contentView = contentView
        self.backgroundURLLink = backgroundURLLink
    }
    
    var body: some View {
        if let backgroundURLLink {
            VStack {
                headerView
                contentView
                    .padding(.horizontal, 5)
            }
            .padding(.bottom, 0)
            .background{
                RemoteImageView(urlString: backgroundURLLink, size: 100)
            }
            
        } else {
            VStack {
                headerView
                contentView
                    .padding(.horizontal, 5)
            }
            .padding(.bottom, 0)
        }
    }
}


protocol RouteMenu: CaseIterable, Hashable {
    var title: String { get }
    var icon: String { get }
    var color: Color { get }
    @ViewBuilder
    func getIconView() -> AnyView
    @ViewBuilder
    func getIconView(active: Bool) -> AnyView
    @ViewBuilder
    func getView() -> AnyView
}

extension RouteMenu {
    @ViewBuilder
    func getView() -> AnyView {
        AnyView(EmptyView())
    }
}

struct MenuRouteView<T: RouteMenu & RawRepresentable>: View where T.RawValue == String {
    
    @Binding var menu: T
    @Environment(\.colorScheme) var colorScheme
    @Namespace var animation
    
    let animationName: String
    
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(Array(T.allCases), id: \.self) { item in
                MenuTabIndicatorView(
                    menu: item,
                    isSelected: menu == item
                )
                .themedBackground(.itemSelected(
                    tintColor: .backgroundColor(for: colorScheme),
                    isSelected: menu == item,
                    animationID: animation,
                    animationName: animationName
                ))
                .onTapGesture {
                    withAnimation {
                        menu = item
                    }
                }
                .id(item)
            }
        }
        .padding(5)
        .padding(.horizontal, 5)
        .themedBackground(.card(tintColor: .backgroundColor(for: colorScheme), material: .none))
        .padding(.horizontal, 5)
    }
}

struct TabViewByMenuRouteView<T: RouteMenu & RawRepresentable>: View where T.RawValue == String {
    
    @Binding var menu: T
    @State private var loadedTabs: Set<T> = []
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        TabView (selection: $menu) {
            ForEach(Array(T.allCases), id: \.self) { item in
                item.getView()
                    .tag(item)
            }
        }
        .padding(10)
        .themedBackground(.card(tintColor: .backgroundColor(for: colorScheme)))
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.2), value: menu)
    }
}


struct RouteHeaderView<Content: View>: View {
    var backRouteAction: () -> Void
    var contentView: Content
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        HStack {
            Button(action: {
                backRouteAction()
            }, label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
            })
            
            contentView
            Spacer()
        }
        .padding(.horizontal, 16)
        .themedBackground(.header(tintColor: .backgroundColor(for: colorScheme), height: 70))
    }
}

struct LazyTabContent<Content: View, Menu: RouteMenu>: View {
    var menu: Menu
    let isSelected: Bool
    @Binding var loadedTabs: Set<Menu>
    let content: () -> Content
    
    var body: some View {
        Group {
            if loadedTabs.contains(menu) {
                content()
            } else {
                Color.clear
                    .onAppear {
                        if isSelected {
                            loadedTabs.insert(menu)
                        }
                    }
            }
        }
        .onChange(of: isSelected) { ol, newValue in
            if newValue && !loadedTabs.contains(menu) {
                loadedTabs.insert(menu)
            }
        }
    }
}
