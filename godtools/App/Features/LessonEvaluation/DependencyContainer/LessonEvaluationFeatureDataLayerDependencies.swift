//
//  LessonEvaluationFeatureDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RepositorySync

class LessonEvaluationFeatureDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
        
    func getLessonEvaluationRepository() -> LessonEvaluationRepository {
        
        let persistence: any Persistence<LessonEvaluationDataModel, LessonEvaluationDataModel>
        
        if #available(iOS 17.4, *), let database = coreDataLayer.getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                dataModelMapping: SwiftLessonEvaluationMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                database: coreDataLayer.getSharedRealmDatabase(),
                dataModelMapping: RealmLessonEvaluationMapping()
            )
        }
        
        return LessonEvaluationRepository(
            cache: LessonEvaluationCache(
                persistence: persistence
            )
        )
    }
    
    func getLessonFeedbackAnalytics() -> LessonFeedbackAnalytics {
        return LessonFeedbackAnalytics(
            firebaseAnalytics: coreDataLayer.getAnalytics().firebaseAnalytics
        )
    }
}
