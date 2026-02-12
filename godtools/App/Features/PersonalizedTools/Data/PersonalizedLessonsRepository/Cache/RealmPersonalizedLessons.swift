//
//  RealmPersonalizedLessons.swift
//  godtools
//
//  Created by Rachael Skeath on 1/26/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmPersonalizedLessons: Object {

    @objc dynamic var id: String = ""
    @objc dynamic var updatedAt: Date = Date()

    let resourceIds = List<String>()

    override static func primaryKey() -> String? {
        return "id"
    }

    func getResourceIds() -> [String] {
        return Array(resourceIds)
    }

    static func createId(country: String?, language: String) -> String {
        if let country = country, !country.isEmpty {
            return "\(country)_\(language)"
        } else {
            return language
        }
    }
}
