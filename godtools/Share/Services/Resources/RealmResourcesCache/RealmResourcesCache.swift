//
//  RealmResourcesCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmResourcesCache {
    
    typealias SHA256PlusPathExtension = String
    typealias ResourceId = String
    typealias LanguageId = String
    typealias TranslationId = String
    
    let realmDatabase: RealmDatabase
    
    required init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func cacheResources(languages: [LanguageModel], resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel, complete: @escaping ((_ result: Result<ResourcesDownloaderResult, Error>) -> Void)) {
                
        realmDatabase.background { (realm: Realm) in
            
            var realmObjectsToCache: [Object] = Array()
            var realmLanguagesDictionary: [LanguageId: RealmLanguage] = Dictionary()
            var realmResourcesDictionary: [ResourceId: RealmResource] = Dictionary()
            var realmTranslationsDictionary: [TranslationId: RealmTranslation] = Dictionary()
            
            var attachmentsGroupedBySHA256WithPathExtension: [SHA256PlusPathExtension: AttachmentFile] = Dictionary()
            
            for language in languages {
                
                let realmLanguage: RealmLanguage = RealmLanguage()
                realmLanguage.mapFrom(model: language)
                realmLanguagesDictionary[realmLanguage.id] = realmLanguage
                realmObjectsToCache.append(realmLanguage)
            }
            
            for resource in resourcesPlusLatestTranslationsAndAttachments.resources {
                
                let realmResource = RealmResource()
                realmResource.mapFrom(model: resource)
                realmResourcesDictionary[realmResource.id] = realmResource
                realmObjectsToCache.append(realmResource)
            }
            
            for translation in resourcesPlusLatestTranslationsAndAttachments.translations {
                
                let realmTranslation = RealmTranslation()
                realmTranslation.mapFrom(model: translation)
                
                if let resourceId = translation.resource?.id {
                    realmTranslation.resource = realmResourcesDictionary[resourceId]
                }
                
                if let languageId = translation.language?.id {
                    realmTranslation.language = realmLanguagesDictionary[languageId]
                }
                
                realmTranslationsDictionary[realmTranslation.id] = realmTranslation
                realmObjectsToCache.append(realmTranslation)
            }
            
            for attachment in resourcesPlusLatestTranslationsAndAttachments.attachments {
                
                let realmAttachment = RealmAttachment()
                realmAttachment.mapFrom(model: attachment)
                
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
            }
            
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
            
            do {
                try realm.write {
                    realm.add(realmObjectsToCache, update: .all)
                }
                complete(.success(ResourcesDownloaderResult(latestAttachmentFiles: Array(attachmentsGroupedBySHA256WithPathExtension.values))))
            }
            catch let error {
                assertionFailure(error.localizedDescription)
                complete(.failure(error))
            }
        }
    }
    
    func getResources(completeOnMain: @escaping ((_ resources: [ResourceModel]) -> Void)) {
        realmDatabase.background { [unowned self] (realm: Realm) in
            let resources: [ResourceModel] = self.getResources(realm: realm).map({ResourceModel(realmResource: $0)})
            DispatchQueue.main.async {
                completeOnMain(resources)
            }
        }
    }
    
    func getResources(realm: Realm) -> [RealmResource] {
        let realmResources: [RealmResource] = Array(realm.objects(RealmResource.self))
        return realmResources
    }
    
    func getResource(id: String, completeOnMain: @escaping ((_ resource: ResourceModel?) -> Void)) {
        realmDatabase.background { [unowned self] (realm: Realm) in
            let resource: ResourceModel?
            if let realmResource = self.getResource(realm: realm, id: id) {
                resource = ResourceModel(realmResource: realmResource)
            }
            else {
                resource = nil
            }
            DispatchQueue.main.async {
                completeOnMain(resource)
            }
        }
    }
    
    func getResources(resourceIds: [String], completeOnMain: @escaping ((_ resources: [ResourceModel]) -> Void)) {
        realmDatabase.background { [weak self] (realm: Realm) in
            var resources: [ResourceModel] = Array()
            for resourceId in resourceIds {
                if let realmResource = self?.getResource(realm: realm, id: resourceId) {
                    resources.append(ResourceModel(realmResource: realmResource))
                }
            }
            DispatchQueue.main.async {
                completeOnMain(resources)
            }
        }
    }
    
    func getResource(realm: Realm, id: String) -> RealmResource? {
        return realm.object(ofType: RealmResource.self, forPrimaryKey: id)
    }
        
    func getLanguages(completeOnMain: @escaping ((_ languages: [LanguageModel]) -> Void)) {
        realmDatabase.background { [unowned self] (realm: Realm) in
            let languages: [LanguageModel] = self.getLanguages(realm: realm).map({LanguageModel(realmLanguage: $0)})
            DispatchQueue.main.async {
                completeOnMain(languages)
            }
        }
    }
    
    func getLanguages(realm: Realm) -> [RealmLanguage] {
        let realmLanguages: [RealmLanguage] = Array(realm.objects(RealmLanguage.self))
        return realmLanguages
    }
    
    func getLanguage(id: String, completeOnMain: @escaping ((_ language: LanguageModel?) -> Void)) {
        realmDatabase.background { [unowned self] (realm: Realm) in
            let language: LanguageModel?
            if let realmLanguage = self.getLanguage(realm: realm, id: id) {
                language = LanguageModel(realmLanguage: realmLanguage)
            }
            else {
                language = nil
            }
            DispatchQueue.main.async {
                completeOnMain(language)
            }
        }
    }
    
    func getLanguage(realm: Realm, id: String) -> RealmLanguage? {
        return realm.object(ofType: RealmLanguage.self, forPrimaryKey: id)
    }
    
    func getResourceLanguageTranslation(resourceId: String, languageId: String, completeOnMain: @escaping ((_ translation: TranslationModel?) -> Void)) {
        
        realmDatabase.background { (realm: Realm) in
            
            let realmResource: RealmResource? = realm.object(ofType: RealmResource.self, forPrimaryKey: resourceId)
            let realmTranslation: RealmTranslation? = realmResource?.latestTranslations.filter("language.id = '\(languageId)'").first
            let translation: TranslationModel?
            if let realmTranslation = realmTranslation {
                translation = TranslationModel(realmTranslation: realmTranslation)
            }
            else {
                translation = nil
            }
            
            DispatchQueue.main.async {
                completeOnMain(translation)
            }
        }
    }
}
