//
//  CompetitionMatches.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

import Foundation



// MARK: - Match








// MARK: - Season
struct SeasonSimple {
    var id: Int?
    var startDate, endDate: String?
    var currentMatchday: Int?
    var winner: String?
    
    var years: String {
        return yearStart + " - " + yearEnd
    }
    
    var yearStart: String {
        return DateParser.convert(startDate ?? "", to: "yyyy")
    }
    
    var yearEnd: String {
        return DateParser.convert(endDate ?? "", to: "yyyy")
    }
    
    var fromDateToDate: String {
        return DateParser.convert(startDate ?? "", to: "dd/MM/yyyy") + " - " + DateParser.convert(endDate ?? "", to: "dd/MM/yyyy")
    }
}

