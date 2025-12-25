//
//  Competition.swift
//  FootballDt
//
//  Created by Macbook on 24/12/25.
//

struct Competition {
    var id: Int
    var area: Area?
    var name: String
    var code: String?
    var type: String?
    var emblem: String?
    var plan: String?
    var currentSeason: Season?
    var numberOfAvailableSeasons: Int?
    var lastUpdated: String?
    
    
}

struct Area {
    var id: Int
    var name: String?
    var countryCode: String?
    var code: String?
    var flag: String?
    var parentAreaID: Int?
    var parentArea: String?
    
    
    init() {
        self.id = 0
        self.name = ""
    }
    
    init(id: Int, name: String?, countryCode: String? = nil, code: String? = nil, flag: String? = nil, parentAreaID: Int? = nil, parentArea: String? = nil) {
        self.id = id
        self.name = name
        self.countryCode = countryCode
        self.code = code
        self.flag = flag
        self.parentAreaID = parentAreaID
        self.parentArea = parentArea
    }
}


struct Season: Codable {
    var id: Int
    var startDate, endDate: String
    var currentMatchday: Int?
    var winner: Winner?
    
    var years: String {
        return yearStart + " - " + yearEnd
    }
    
    var yearStart: String {
        return DateParser.convert(startDate, to: "yyyy")
    }
    
    var yearEnd: String {
        return DateParser.convert(endDate, to: "yyyy")
    }
    
    var fromDateToDate: String {
        return DateParser.convert(startDate, to: "dd/MM/yyyy") + " - " + DateParser.convert(endDate, to: "dd/MM/yyyy")
    }
}


// MARK: - Winner
struct Winner: Codable {
    var id: Int
    var name: String
    var shortName, tla: String?
    var crest: String?
    var address: String
    var website: String?
    var founded: Int?
    var clubColors, venue: String?
    var lastUpdated: String
}
