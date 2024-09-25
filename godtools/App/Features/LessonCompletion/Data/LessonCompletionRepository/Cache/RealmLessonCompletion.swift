//
//  RealmLessonCompletion.swift
//  godtools
//
//  Created by Rachael Skeath on 9/25/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmLessonCompletion: Object {
    
    @objc dynamic var lessonId: String = ""
    @objc dynamic var progress: Double = 0.0
    
    override class func primaryKey() -> String? {
        return "lessonId"
    }
}
