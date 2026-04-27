//
//  LessonEvaluationCache.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

final class LessonEvaluationCache {
    
    let persistence: any Persistence<LessonEvaluationDataModel, LessonEvaluationDataModel>
    
    init(persistence: any Persistence<LessonEvaluationDataModel, LessonEvaluationDataModel>) {
                
        self.persistence = persistence
    }
    
    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<LessonEvaluationDataModel, LessonEvaluationDataModel, SwiftLessonEvaluation>? {
        return persistence as? SwiftRepositorySyncPersistence<LessonEvaluationDataModel, LessonEvaluationDataModel, SwiftLessonEvaluation>
    }
    
    private var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<LessonEvaluationDataModel, LessonEvaluationDataModel, RealmLessonEvaluation>? {
        return persistence as? RealmRepositorySyncPersistence<LessonEvaluationDataModel, LessonEvaluationDataModel, RealmLessonEvaluation>
    }
}
