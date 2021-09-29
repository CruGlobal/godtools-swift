//
//  RealmEvaluatedLesson.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmEvaluatedLesson: Object {
    
    @objc dynamic var lessonAbbreviation: String = ""
    @objc dynamic var lessonId: String = ""
    
    override static func primaryKey() -> String? {
        return "lessonId"
    }
    
    func mapFrom(model: EvaluatedLessonModel, ignorePrimaryKey: Bool) {
        
        if !ignorePrimaryKey {
            lessonId = model.lessonId
        }
        
        lessonAbbreviation = model.lessonAbbreviation
    }
}
