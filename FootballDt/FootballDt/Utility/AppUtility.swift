//
//  AppUtility.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import Foundation

class AppUtility {
    static let envDict = Bundle.main.infoDictionary?["LSEnvironment"] as! Dictionary<String, String>
    static let FootballDtBaseURL = envDict["BaseURL_FootballDt"]! as String
    static let AuthTK = envDict["AuthTK"]! as String
}

enum DateParser {

    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let dateOnlyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    static func parse(_ raw: String) -> Date? {

        // ISO 8601: 2023-08-01T08:40:24Z
        if let date = isoFormatter.date(from: raw) {
            return date
        }

        // Date-only: 2021-03-13
        if let date = dateOnlyFormatter.date(from: raw) {
            return date
        }

        return nil
    }
    
    static func formatDate(_ date: Date, to format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
