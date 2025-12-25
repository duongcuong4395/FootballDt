//
//  RemoteImageKit.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import SwiftUI

enum RemoteImageType {
    case png
    case svg
    case unknown
}

enum RemoteImageResolver {

    static func resolve(from urlString: String?) -> RemoteImageType {
        guard let urlString,
              let ext = URL(string: urlString)?.pathExtension.lowercased()
        else { return .unknown }

        switch ext {
        case "png", "jpg", "jpeg", "webp":
            return .png
        case "svg":
            return .svg
        default:
            return .unknown
        }
    }
}

import SwiftUI
import Kingfisher
import SDWebImageSwiftUI

struct RemoteImageView: View {

    let urlString: String?
    let size: CGFloat

    var body: some View {
        switch RemoteImageResolver.resolve(from: urlString) {

        case .png:
            KFImage(URL(string: urlString ?? ""))
                .placeholder {
                    ProgressView()
                }
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)

        case .svg:
            WebImage(url: URL(string: urlString ?? ""))
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)

        case .unknown:
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .foregroundColor(.gray)
        }
    }
}
