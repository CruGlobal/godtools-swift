//
//  UserCounterDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 11/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct UserCounterDataModel: Decodable {
    
    let id: String
    let count: Int
    let decayedCount: Double?
    let lastDecay: Date?
    
    enum RootKeys: String, CodingKey {
        case id
        case attributes
    }
    
    enum AttributesKeys: String, CodingKey {
        case count
        case decayedCount = "decayed-count"
        case lastDecay = "last-decay"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        
        let attributesContainer = try container.nestedContainer(keyedBy: AttributesKeys.self, forKey: .attributes)
        
        count = try attributesContainer.decode(Int.self, forKey: .count)
        decayedCount = try attributesContainer.decodeIfPresent(Double.self, forKey: .decayedCount)
        
        let lastDecayDateString = try attributesContainer.decodeIfPresent(String.self, forKey: .lastDecay) ?? ""
        lastDecay = UserCounterDataModel.parseLastDecayDateFromString(lastDecayDateString)
    }
    
    init(realmUserCounter: RealmUserCounter) {
        
        id = realmUserCounter.id
        count = realmUserCounter.count
        decayedCount = realmUserCounter.decayedCount
        lastDecay = realmUserCounter.lastDecay
    }
    
    private static func parseLastDecayDateFromString(_ dateString: String) -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [
            .withFullDate,
            .withDashSeparatorInDate
        ]
        
        return dateFormatter.date(from: dateString)
    }
}
