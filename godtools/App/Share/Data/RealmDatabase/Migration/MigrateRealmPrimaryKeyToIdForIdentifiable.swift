//
//  MigrateRealmPrimaryKeyToIdForIdentifiable.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RealmSwift

final class MigrateRealmPrimaryKeyToIdForIdentifiable: RealmMigrationInterface {
    
    private struct Object {
        let className: String
        let primaryKey: String
    }
    
    let shouldMigrate: Bool
    
    init(oldSchemaVersion: UInt64) {
        
        shouldMigrate = oldSchemaVersion < 44
    }
    
    func migrate(migration: Migration) {
        
        let realmObjectsToMigrate = Self.getRealmObjectsToMigrate()
        
        for object in realmObjectsToMigrate {
            migrateObject(object: object, migration: migration)
        }
    }
    
    private func migrateObject(object: Object, migration: Migration) {
        
        migration.enumerateObjects(ofType: object.className) { (oldObject: MigrationObject?, newObject: MigrationObject?) in

            let primaryKeyValue: String = oldObject?[object.primaryKey] as? String ?? ""
                        
            newObject?["id"] = primaryKeyValue
        }
    }
    
    private static func getRealmObjectsToMigrate() -> [MigrateRealmPrimaryKeyToIdForIdentifiable.Object] {
        
        return [
            Object(
                className: RealmDownloadedLanguage.className(),
                primaryKey: #keyPath(RealmDownloadedLanguage.languageId)
            ),
            Object(
                className: RealmLessonEvaluation.className(),
                primaryKey: #keyPath(RealmLessonEvaluation.lessonId)
            ),
            Object(
                className: RealmUserLessonLanguageFilter.className(),
                primaryKey: #keyPath(RealmUserLessonLanguageFilter.filterId)
            ),
            Object(
                className: RealmUserToolSettings.className(),
                primaryKey: #keyPath(RealmUserToolSettings.toolId)
            ),
            Object(
                className: RealmUserToolCategoryFilter.className(),
                primaryKey: #keyPath(RealmUserToolCategoryFilter.filterId)
            ),
            Object(
                className: RealmUserToolLanguageFilter.className(),
                primaryKey: #keyPath(RealmUserToolLanguageFilter.filterId)
            ),
            Object(
                className: RealmArticleAemData.className(),
                primaryKey: #keyPath(RealmArticleAemData.aemUri)
            ),
            Object(
                className: RealmArticleJcrContent.className(),
                primaryKey: #keyPath(RealmArticleJcrContent.uuid)
            ),
            Object(
                className: RealmCategoryArticle.className(),
                primaryKey: #keyPath(RealmCategoryArticle.uuid)
            ),
            Object(
                className: RealmEmailSignUp.className(),
                primaryKey: #keyPath(RealmEmailSignUp.email)
            ),
            Object(
                className: RealmFavoritedResource.className(),
                primaryKey: #keyPath(RealmFavoritedResource.resourceId)
            ),
            Object(
                className: RealmMobileContentAuthToken.className(),
                primaryKey: #keyPath(RealmMobileContentAuthToken.userId)
            ),
            Object(
                className: RealmSHA256File.className(),
                primaryKey: #keyPath(RealmSHA256File.sha256WithPathExtension)
            ),
            Object(
                className: RealmResourceView.className(),
                primaryKey: #keyPath(RealmResourceView.resourceId)
            ),
            Object(
                className: RealmDownloadedTranslation.className(),
                primaryKey: #keyPath(RealmDownloadedTranslation.translationId)
            )
        ]
    }
}
