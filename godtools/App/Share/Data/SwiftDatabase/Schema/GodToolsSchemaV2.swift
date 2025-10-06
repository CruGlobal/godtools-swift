//
//  GodToolsSchemaV2.swift
//  godtools
//
//  Created by Levi Eggert on 10/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftData

@available(iOS 17, *)
enum GodToolsSchemaV2: VersionedSchema {
    
    static let versionIdentifier = Schema.Version(2, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        return [
            TestMigrationModelV2.TestMigrationModel.self,
            SwiftAppLanguage.self,
            SwiftUserAppLanguage.self,
            SwiftGlobalAnalytics.self,
            SwiftLessonEvaluation.self,
            SwiftToolScreenTutorialShareView.self,
            SwiftArticleAemData.self,
            SwiftArticleJrcContent.self,
            SwiftCategoryArticle.self,
            SwiftEmailSignUp.self,
            SwiftFavoritedResource.self,
            SwiftFollowUp.self,
            SwiftMobileContentAuthToken.self,
            SwiftResourceView.self,
            SwiftDownloadedTranslation.self,
            SwiftAttachment.self,
            SwiftTranslation.self,
            SwiftResource.self,
            SwiftLanguage.self
        ]
    }
}
