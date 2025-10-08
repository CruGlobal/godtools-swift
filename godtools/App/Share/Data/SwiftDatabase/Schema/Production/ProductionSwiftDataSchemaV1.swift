//
//  ProductionSwiftDataSchemaV1.swift
//  godtools
//
//  Created by Levi Eggert on 10/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
enum ProductionSwiftDataSchemaV1: VersionedSchema {
    
    static let versionIdentifier = Schema.Version(1, 0, 0)
        
    static var models: [any PersistentModel.Type] {
        return [
            SwiftAppLanguageV1.SwiftAppLanguage.self,
            SwiftUserAppLanguageV1.SwiftUserAppLanguage.self,
            SwiftGlobalAnalyticsV1.SwiftGlobalAnalytics.self,
            SwiftLessonEvaluationV1.SwiftLessonEvaluation.self,
            SwiftToolScreenTutorialShareViewV1.SwiftToolScreenTutorialShareView.self,
            SwiftArticleAemDataV1.SwiftArticleAemData.self,
            SwiftArticleJrcContentV1.SwiftArticleJrcContent.self,
            SwiftCategoryArticleV1.SwiftCategoryArticle.self,
            SwiftEmailSignUpV1.SwiftEmailSignUp.self,
            SwiftFavoritedResourceV1.SwiftFavoritedResource.self,
            SwiftFollowUpV1.SwiftFollowUp.self,
            SwiftMobileContentAuthTokenV1.SwiftMobileContentAuthToken.self,
            SwiftResourceViewV1.SwiftResourceView.self,
            SwiftDownloadedTranslationV1.SwiftDownloadedTranslation.self,
            SwiftAttachmentV1.SwiftAttachment.self,
            SwiftTranslationV1.SwiftTranslation.self,
            SwiftResourceV1.SwiftResource.self,
            SwiftLanguageV1.SwiftLanguage.self,
            SwiftUserCounterV1.SwiftUserCounter.self,
            SwiftCompletedTrainingTipV1.SwiftCompletedTrainingTip.self,
            SwiftUserLessonProgressV1.SwiftUserLessonProgress.self
        ]
    }
}
