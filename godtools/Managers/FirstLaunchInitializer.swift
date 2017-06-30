//
//  FirstLaunchInitializer.swift
//  godtools
//
//  Created by Ryan Carlson on 5/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import CoreData

class FirstLaunchInitializer: GTDataManager {
    
    private let magicId = "temporaryRecordId"
    private let initialPackageCodes = ["kgp", "4sl", "sat"]
    
    func initializeAppState() {
        initializeInitialLanguages()
        let englishLanguage = findEntity(Language.self, byAttribute: "code", withValue: "en")!
        
        safelyWriteToRealm {
            let resources = initializeInitialResources(language: englishLanguage)
            initializeInitialTranslations(language: englishLanguage, resources: resources)
        }
        
        GTSettings.shared.primaryLanguageId = magicId
    }
    
    func cleanupInitialAppState() {
        let predicate = NSPredicate(format: "remoteId = %@", magicId)
        
        safelyWriteToRealm {
            realm.delete(findEntities(Translation.self, matching: predicate))
            realm.delete(findEntities(Language.self, matching: predicate))
            realm.delete(findEntities(DownloadedResource.self, matching: predicate))
            
            if GTSettings.shared.primaryLanguageId == magicId {
                let primaryLanguageCode = Locale.preferredLanguages.first ?? "en"
                let primaryLanguage = findEntity(Language.self, byAttribute: "code", withValue: primaryLanguageCode) ??
                    findEntity(Language.self, byAttribute: "code", withValue: "en")
                
                primaryLanguage?.shouldDownload = true
                
                for resource in findEntities(DownloadedResource.self, matching: NSPredicate(format:"code IN %@", initialPackageCodes)) {
                    resource.shouldDownload = true
                }
                
                GTSettings.shared.primaryLanguageId = primaryLanguage?.remoteId
            }
            
        }
        sendCompletedNotification()
    }
    
    private func initializeInitialLanguages() {
        LanguagesManager().loadInitialContentFromDisk()
    }
    
    private func initializeInitialResources(language: Language?) -> [DownloadedResource] {
        let kgp = DownloadedResource()
        kgp.code = "kgp"
        kgp.name = "Knowing God Personally"
        kgp.remoteId = magicId
        kgp.shouldDownload = true
        
        let fourlaws = DownloadedResource()
        fourlaws.code = "4sl"
        fourlaws.name = "Four Spiritual Laws"
        fourlaws.remoteId = magicId
        fourlaws.shouldDownload = true
        
        let satisfied = DownloadedResource()
        satisfied.code = "satisfied"
        satisfied.name = "Satisfied?"
        satisfied.remoteId = magicId
        satisfied.shouldDownload = true
        
        return [kgp, fourlaws, satisfied]
    }
    
    private func initializeInitialTranslations(language: Language,
                                               resources: [DownloadedResource]) {
        for resource in resources {
            let translation = Translation()
            
            translation.remoteId = magicId
            translation.isPublished = true
            translation.isDownloaded = true
            translation.version = 0
            translation.localizedName = resource.name
            
            language.translations.append(translation)
            resource.translations.append(translation)
        }
    }
    
    private func sendCompletedNotification() {
        NotificationCenter.default.post(name: .initialAppStateCleanupCompleted, object: nil)
    }
}
