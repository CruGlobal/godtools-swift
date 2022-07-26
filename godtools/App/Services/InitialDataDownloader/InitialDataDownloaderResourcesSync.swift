//
//  InitialDataDownloaderResourcesSync.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class InitialDataDownloaderResourcesSync {
    
    typealias SHA256PlusPathExtension = String
        typealias ResourceId = String
        typealias LanguageId = String
        typealias TranslationId = String
        
        private let realmDatabase: RealmDatabase
        
        required init(realmDatabase: RealmDatabase) {
            
            self.realmDatabase = realmDatabase
        }
        
        var resourcesAvailable: Bool {
            let realm: Realm = realmDatabase.mainThreadRealm
            return !realm.objects(RealmResource.self).isEmpty &&
                !realm.objects(RealmLanguage.self).isEmpty &&
                !realm.objects(RealmTranslation.self).isEmpty &&
                !realm.objects(RealmAttachment.self).isEmpty
        }
        
        func cacheResources(realm: Realm, downloaderResult: ResourcesDownloaderResult) -> Result<ResourcesCacheResult, Error> {
                
            let languages: [LanguageModel] = downloaderResult.languages
            let resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel = downloaderResult.resourcesPlusLatestTranslationsAndAttachments
            
            var realmLanguagesDictionary: [LanguageId: RealmLanguage] = Dictionary()
            var realmResourcesDictionary: [ResourceId: RealmResource] = Dictionary()
            var realmTranslationsDictionary: [TranslationId: RealmTranslation] = Dictionary()
            
            var attachmentsGroupedBySHA256WithPathExtension: [SHA256PlusPathExtension: AttachmentFile] = Dictionary()
            
            var realmObjectsToCache: [Object] = Array()
            
            // parse langauges
            
            var languageIdsRemoved: [String] = Array(realm.objects(RealmLanguage.self)).map({$0.id})
            
            if !languages.isEmpty {
                
                for language in languages {
                    
                    let realmLanguage: RealmLanguage = RealmLanguage()
                    realmLanguage.mapFrom(model: language, shouldIgnoreMappingPrimaryKey: false)
                    realmLanguagesDictionary[realmLanguage.id] = realmLanguage
                    realmObjectsToCache.append(realmLanguage)
                    
                    if let index = languageIdsRemoved.firstIndex(of: language.id) {
                        languageIdsRemoved.remove(at: index)
                    }
                }
            }
            else {
                languageIdsRemoved = []
            }
            
            // parse resources
            
            var resourceIdsRemoved: [String] = Array(realm.objects(RealmResource.self)).map({$0.id})
            
            if !resourcesPlusLatestTranslationsAndAttachments.resources.isEmpty {
                
                for resource in resourcesPlusLatestTranslationsAndAttachments.resources {
                    
                    let realmResource = RealmResource()
                    realmResource.mapFrom(model: resource, shouldIgnoreMappingPrimaryKey: false)
                    realmResourcesDictionary[realmResource.id] = realmResource
                    realmObjectsToCache.append(realmResource)
                    
                    if let index = resourceIdsRemoved.firstIndex(of: resource.id) {
                        resourceIdsRemoved.remove(at: index)
                    }
                }
            }
            else {
                resourceIdsRemoved = []
            }
            
            // parse latest translations
            
            var translationIdsRemoved: [String] = Array(realm.objects(RealmTranslation.self)).map({$0.id})
            
            if !resourcesPlusLatestTranslationsAndAttachments.translations.isEmpty {
                
                for translation in resourcesPlusLatestTranslationsAndAttachments.translations {
                    
                    let realmTranslation = RealmTranslation()
                    realmTranslation.mapFrom(model: translation, shouldIgnoreMappingPrimaryKey: false)
                    
                    if let resourceId = translation.resource?.id {
                        realmTranslation.resource = realmResourcesDictionary[resourceId]
                    }
                    
                    if let languageId = translation.language?.id {
                        realmTranslation.language = realmLanguagesDictionary[languageId]
                    }
                    
                    realmTranslationsDictionary[realmTranslation.id] = realmTranslation
                    realmObjectsToCache.append(realmTranslation)
                    
                    if let index = translationIdsRemoved.firstIndex(of: translation.id) {
                        translationIdsRemoved.remove(at: index)
                    }
                }
            }
            else {
                translationIdsRemoved = []
            }
            
            // parse latest attachments
            
            var attachmentIdsRemoved: [String] = Array(realm.objects(RealmAttachment.self)).map({$0.id})
            
            if !resourcesPlusLatestTranslationsAndAttachments.attachments.isEmpty {
                
                for attachment in resourcesPlusLatestTranslationsAndAttachments.attachments {
                    
                    let realmAttachment = RealmAttachment()
                    realmAttachment.mapFrom(model: attachment, shouldIgnoreMappingPrimaryKey: false)
                    
                    if let resourceId = attachment.resource?.id {
                        realmAttachment.resource = realmResourcesDictionary[resourceId]
                    }
                    
                    realmObjectsToCache.append(realmAttachment)
                    
                    let sha256WithPathExtension: String = realmAttachment.sha256FileLocation.sha256WithPathExtension
                    
                    if let attachmentFile = attachmentsGroupedBySHA256WithPathExtension[sha256WithPathExtension] {
                        attachmentFile.addAttachmentId(attachmentId: realmAttachment.id)
                    }
                    else if let remoteFileUrl = URL(string: realmAttachment.file) {
                        let attachmentFile: AttachmentFile = AttachmentFile(
                            remoteFileUrl: remoteFileUrl,
                            sha256: realmAttachment.sha256,
                            pathExtension: remoteFileUrl.pathExtension
                        )
                        attachmentFile.addAttachmentId(attachmentId: realmAttachment.id)
                        attachmentsGroupedBySHA256WithPathExtension[sha256WithPathExtension] = attachmentFile
                    }
                    
                    if let index = attachmentIdsRemoved.firstIndex(of: attachment.id) {
                        attachmentIdsRemoved.remove(at: index)
                    }
                }
            }
            else {
                attachmentIdsRemoved = []
            }
            
            // add latest translations and add languages to resource
            for ( _, realmResource) in realmResourcesDictionary {
                for translationId in realmResource.latestTranslationIds {
                    if let realmTranslation = realmTranslationsDictionary[translationId] {
                        realmResource.latestTranslations.append(realmTranslation)
                        if let realmLanguage = realmTranslation.language {
                            realmResource.languages.append(realmLanguage)
                        }
                    }
                }
            }
            
            // delete realm objects that no longer exist
            var realmObjectsToRemove: [Object] = Array()
            
            let resourcesToRemove: [RealmResource] = realmDatabase.getObjects(realm: realm, primaryKeys: resourceIdsRemoved)
            let languagesToRemove: [RealmLanguage] = realmDatabase.getObjects(realm: realm, primaryKeys: languageIdsRemoved)
            let translationsToRemove: [RealmTranslation] = realmDatabase.getObjects(realm: realm, primaryKeys: translationIdsRemoved)
            let attachmentsToRemove: [RealmAttachment] = realmDatabase.getObjects(realm: realm, primaryKeys: attachmentIdsRemoved)
            
            realmObjectsToRemove.append(contentsOf: resourcesToRemove)
            realmObjectsToRemove.append(contentsOf: languagesToRemove)
            realmObjectsToRemove.append(contentsOf: translationsToRemove)
            realmObjectsToRemove.append(contentsOf: attachmentsToRemove)

            do {
                try realm.write {
                    realm.add(realmObjectsToCache, update: .all)
                    // TODO: Will need to implement clean up of deleted resources. ~Levi
                    //realm.delete(realmObjectsToRemove)
                    // TODO: Only deleting languages.  Will need to delete resources, attachments, translations and test. ~Levi
                    realm.delete(languagesToRemove)
                }
                
                let cacheResult = ResourcesCacheResult(
                    resourceIdsRemoved: resourceIdsRemoved,
                    languageIdsRemoved: languageIdsRemoved,
                    translationIdsRemoved: translationIdsRemoved,
                    attachmentIdsRemoved: attachmentIdsRemoved,
                    latestAttachmentFiles: Array(attachmentsGroupedBySHA256WithPathExtension.values)
                )
                
                return .success(cacheResult)
            }
            catch let error {
                return .failure(error)
            }
        }
}
