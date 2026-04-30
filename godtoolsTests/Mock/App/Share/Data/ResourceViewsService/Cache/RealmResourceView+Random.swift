//
//  RealmResourceView+Random.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools

extension RealmResourceView {
    static func random() -> RealmResourceView {
        let object = RealmResourceView()
        object.resourceId = UUID().uuidString
        return object
    }
}
