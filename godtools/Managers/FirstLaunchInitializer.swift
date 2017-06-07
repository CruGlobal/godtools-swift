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
    private let initialPackageCodes = ["kgp", "fourlaws", "sat"]
    
    func initializeAppState() {
        let language = initializeInitialLanguage()
        let resources = initializeInitialResources(language: language)
        initializeInitialTranslations(language: language, resources: resources)
        
        GTSettings.shared.primaryLanguageId = magicId
    }
    
    func cleanupInitialAppState() {
        let predicate = NSPredicate(format: "remoteId = %@", magicId)
        
        deleteEntities(Translation.self, matching: predicate)
        deleteEntities(Language.self, matching: predicate)
        deleteEntities(DownloadedResource.self, matching: predicate)
        
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
                
        sendCompletedNotification()
    }
    
    private func initializeInitialLanguage() -> Language? {
        let language = createEntity(Language.self)
        
        language?.code = "en-US"
        language?.remoteId = magicId
        
        return language
    }
    
    private func initializeInitialResources(language: Language?) -> [DownloadedResource?] {
        let kgp = createEntity(DownloadedResource.self)
        kgp?.code = "kgp"
        kgp?.name = "Knowing God Personally"
        kgp?.remoteId = magicId
        kgp?.shouldDownload = true
        
        let fourlaws = createEntity(DownloadedResource.self)
        fourlaws?.code = "fourlaws"
        fourlaws?.name = "Four Spiritual Laws"
        fourlaws?.remoteId = magicId
        fourlaws?.shouldDownload = true
        
        let satisfied = createEntity(DownloadedResource.self)
        satisfied?.code = "satisfied"
        satisfied?.name = "Satisfied?"
        satisfied?.remoteId = magicId
        satisfied?.shouldDownload = true
        
        return [kgp, fourlaws, satisfied]
    }
    
    private func initializeInitialTranslations(language: Language?,
                                               resources: [DownloadedResource?]) {
        for resource in resources {
            let translation = createEntity(Translation.self)
            
            translation?.remoteId = magicId
            translation?.isPublished = true
            translation?.isDownloaded = true
            translation?.version = 0
            translation?.localizedName = resource?.name
            
            language?.translations.append(translation!)
            resource?.translations.append(translation!)
        }
    }
    
    private func sendCompletedNotification() {
        NotificationCenter.default.post(name: .initialAppStateCleanupCompleted, object: nil)
    }
}
