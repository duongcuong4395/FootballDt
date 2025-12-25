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

    private static let isoFormatterWithFraction: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    private static let dateOnlyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    static func parse(_ raw: String) -> Date? {

        if let date = isoFormatterWithFraction.date(from: raw) {
            return date
        }

        if let date = isoFormatter.date(from: raw) {
            return date
        }

        if let date = dateOnlyFormatter.date(from: raw) {
            return date
        }

        return nil
    }

    static func format(_ date: Date, to format: String) -> String {
        let f = DateFormatter()
        f.dateFormat = format
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: date)
    }

    static func convert(_ raw: String, to format: String) -> String {
        guard let date = parse(raw) else { return "" }
        return self.format(date, to: format)
    }
}

