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
    static let schemaVersion: UInt64 = 45
    
    static func createConfig() throws -> RealmDatabaseConfig {
        
        let migrationBlock = { @Sendable (migration: Migration, oldSchemaVersion: UInt64) in
            
            let realmMigrations = Self.getMigrations(oldSchemaVersion: oldSchemaVersion)
            
            for realmMigration in realmMigrations {
                
                guard realmMigration.shouldMigrate else {
                    continue
                }
                
                realmMigration.migrate(migration: migration)
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
            RealmToolDownload.self,
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
        
        return try RealmDatabaseConfig(
            fileName: Self.diskFileName,
            schemaVersion: Self.schemaVersion,
            migrationBlock: migrationBlock,
            objectTypes: objectTypes
        )
    }
    
    private static func getMigrations(oldSchemaVersion: UInt64) -> [RealmMigrationInterface] {
        
        return [
            MigrateRealmPrimaryKeyToIdForIdentifiable(oldSchemaVersion: oldSchemaVersion)
        ]
    }
}
