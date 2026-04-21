//
//  RealmFollowUp+Random.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools

extension RealmFollowUp {
    static func random() -> RealmFollowUp {
        let object = RealmFollowUp()
        object.id = UUID().uuidString
        return object
    }
}
