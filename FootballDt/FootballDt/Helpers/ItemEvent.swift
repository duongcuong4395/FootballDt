//
//  ItemEvent.swift
//  FootballDt
//
//  Created by Macbook on 26/12/25.
//

import SwiftUI

enum ItemEvent<T: Equatable> {
    case toggleLike(for: T)
    case viewDetail(for: T)
    case toggleNotify(for: T)
    case tapped(for: T)
    case onApear(for: T)
    case analysis(for: T)
}

enum IconItemType: String {
    case Default = "ellipsis.circle"
    case Down = "chevron.down"
    case Up = "chevron.up"
    case Right = "chevron.right"
    case Route3D = "move.3d"
    case Route = "point.topleft.down.curvedto.point.filled.bottomright.up"
    case RouteBranch = "arrow.triangle.branch"
    case RouteSwap = "arrow.triangle.swap"
    case Star = "wand.and.stars"
    case MultiStar = "sparkles"
    case NotificationOn = "bell.fill"
    case NotificationOff = "bell"
    case openVideo = "play.rectangle"
    case Info = "info.circle"
    case HeartFill = "heart.fill"
    case Heart = "heart"
}

protocol ItemBuilder {
    associatedtype T: Equatable
    func buildOptions(for item: T, send: @escaping (ItemEvent<T>) -> Void) -> AnyView
}

extension ItemBuilder {
    
    @ViewBuilder
    func buildItemButton(with image: IconItemType, action: @escaping () -> Void) -> some View {
        Image(systemName: image.rawValue)
            .font(.title3)
            .padding(6)
            .onTapGesture {
                action()
            }
    }
}
