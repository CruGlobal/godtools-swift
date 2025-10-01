//
//  GodToolsSwiftDataModelTypes.swift
//  godtools
//
//  Created by Levi Eggert on 9/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
class GodToolsSwiftDataModelTypes: SwiftDatabaseModelTypesInterface {
    
    func getModelTypes() -> [any PersistentModel.Type] {
        return [
            TestMigrationModel.self,
            TestMigrationModelSchemaV1.TestMigrationModel.self,
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
