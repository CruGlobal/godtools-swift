//
//  ProductionSwiftDataSchemaV1.swift
//  godtools
//
//  Created by Levi Eggert on 10/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17.4, *)
enum ProductionSwiftDataSchemaV1: VersionedSchema {
    
    static let versionIdentifier = Schema.Version(1, 0, 0)
        
    static var models: [any PersistentModel.Type] {
        return [
            SwiftAppLanguageV1.SwiftAppLanguage.self,
            SwiftArticleAemDataV1.SwiftArticleAemData.self,
            SwiftArticleJrcContentV1.SwiftArticleJrcContent.self,
            SwiftAttachmentV1.SwiftAttachment.self,
            SwiftCategoryArticleV1.SwiftCategoryArticle.self,
            SwiftCompletedTrainingTipV1.SwiftCompletedTrainingTip.self,
            SwiftDownloadedLanguageV1.SwiftDownloadedLanguage.self,
            SwiftDownloadedTranslationV1.SwiftDownloadedTranslation.self,
            SwiftEmailSignUpV1.SwiftEmailSignUp.self,
            SwiftFavoritedResourceV1.SwiftFavoritedResource.self,
            SwiftFollowUpV1.SwiftFollowUp.self,
            SwiftGlobalAnalyticsV1.SwiftGlobalAnalytics.self,
            SwiftLanguageV1.SwiftLanguage.self,
            SwiftLaunchCountV1.SwiftLaunchCount.self,
            SwiftLessonEvaluationV1.SwiftLessonEvaluation.self,
            SwiftLocalActivityCountV1.SwiftLocalActivityCount.self,
            SwiftMobileContentAuthTokenV1.SwiftMobileContentAuthToken.self,
            SwiftPersonalizedToolsV1.SwiftPersonalizedTools.self,
            SwiftResourceV1.SwiftResource.self,
            SwiftResourceViewV1.SwiftResourceView.self,
            SwiftSHA256FileV1.SwiftSHA256File.self,
            SwiftToolDownloadV1.SwiftToolDownload.self,
            SwiftToolScreenTutorialShareViewV1.SwiftToolScreenTutorialShareView.self,
            SwiftTranslationV1.SwiftTranslation.self,
            SwiftUserAppLanguageV1.SwiftUserAppLanguage.self,
            SwiftUserCounterV1.SwiftUserCounter.self,
            SwiftUserDetailsV1.SwiftUserDetails.self,
            SwiftUserLessonLanguageFilterV1.SwiftUserLessonLanguageFilter.self,
            SwiftUserLessonProgressV1.SwiftUserLessonProgress.self,
            SwiftUserLocalizationSettingsV1.SwiftUserLocalizationSettings.self,
            SwiftUserToolCategoryFilterV1.SwiftUserToolCategoryFilter.self,
            SwiftUserToolLanguageFilterV1.SwiftUserToolLanguageFilter.self,
            SwiftUserToolSettingsV1.SwiftUserToolSettings.self
        ]
    }
}
