//
//  RealmProductionConfig.swift
//  godtools
//
//  Created by Levi Eggert on 1/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

final class RealmProductionConfig {
    
    static let diskFileName: String = "godtools_realm"
    static let schemaVersion: UInt64 = 43
    
    func createConfig() -> RealmDatabaseConfig {
        
        let migrationBlock = { @Sendable (migration: Migration, oldSchemaVersion: UInt64) in
                                    
            if (oldSchemaVersion < 1) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
        }
        
        // TODO: Manually adding object types to resolve a crash in iOS 16. If issue is resolved, can this go away for iOS 16? ~Levi
        // Issue here: https://github.com/realm/realm-swift/issues/8794
        
        let objectTypes: [ObjectBase.Type] = [
            RealmAppLanguage.self,
            RealmArticleAemData.self,
            RealmArticleJcrContent.self,
            RealmAttachment.self,
            RealmCategoryArticle.self,
            RealmCompletedTrainingTip.self,
            RealmDownloadedLanguage.self,
            RealmDownloadedTranslation.self,
            RealmEmailSignUp.self,
            RealmFavoritedResource.self,
            RealmFollowUp.self,
            RealmGlobalAnalytics.self,
            RealmLanguage.self,
            RealmLessonEvaluation.self,
            RealmLocalActivityCount.self,
            RealmMobileContentAuthToken.self,
            RealmPersonalizedTools.self,
            RealmResource.self,
            RealmResourceView.self,
            RealmSHA256File.self,
            RealmToolLanguageDownload.self,
            RealmToolScreenShareTutorialView.self,
            RealmTranslation.self,
            RealmUserAppLanguage.self,
            RealmUserCounter.self,
            RealmUserDetails.self,
            RealmUserLessonLanguageFilter.self,
            RealmUserLessonProgress.self,
            RealmUserLocalizationSettings.self,
            RealmUserToolCategoryFilter.self,
            RealmUserToolLanguageFilter.self,
            RealmUserToolSettings.self
        ]
        
        return RealmDatabaseConfig(
            fileName: Self.diskFileName,
            schemaVersion: Self.schemaVersion,
            migrationBlock: migrationBlock,
            objectTypes: objectTypes
        )
    }
}
