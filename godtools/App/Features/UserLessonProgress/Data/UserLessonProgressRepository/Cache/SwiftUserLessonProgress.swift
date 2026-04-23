//
//  SwiftUserLessonProgress.swift
//  godtools
//
//  Created by Rachael Skeath on 10/8/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
typealias SwiftUserLessonProgress = SwiftUserLessonProgressV1.SwiftUserLessonProgress

@available(iOS 17.4, *)
enum SwiftUserLessonProgressV1 {
    
    @Model
    class SwiftUserLessonProgress: IdentifiableSwiftDataObject {
        
        var lastViewedPageId: String = ""
        var progress: Double = 0.0
        
        @Attribute(.unique) var id: String = ""
        @Attribute(.unique) var lessonId: String = ""
        
        init() {
            
        }
    }
}

@available(iOS 17.4, *)
extension SwiftUserLessonProgress {
    
    func mapFrom(model: UserLessonProgressDataModel) {
        
        id = model.id
        lessonId = model.lessonId
        lastViewedPageId = model.lastViewedPageId
        progress = model.progress
    }
    
    static func createNewFrom(model: UserLessonProgressDataModel) -> SwiftUserLessonProgress {
        
        let object = SwiftUserLessonProgress()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> UserLessonProgressDataModel {
        return UserLessonProgressDataModel(
            id: id,
            lessonId: lessonId,
            lastViewedPageId: lastViewedPageId,
            progress: progress
        )
    }
}
