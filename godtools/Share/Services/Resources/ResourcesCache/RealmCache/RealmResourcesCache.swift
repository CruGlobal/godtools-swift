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
    
    private let realmDatabase: RealmDatabase
    
    required init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func cacheResources(languages: [LanguageModel], resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel, complete: @escaping ((_ result: Result<RealmResourcesCacheResult, Error>) -> Void)) {
                
        realmDatabase.background { (realm: Realm) in
            
            var realmObjectsToCache: [Object] = Array()
            var realmLanguagesDictionary: [String: RealmLanguage] = Dictionary()
            var realmResourcesDictionary: [String: RealmResource] = Dictionary()
            var realmTranslationsDictionary: [String: RealmTranslation] = Dictionary()
            
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
                complete(.success(RealmResourcesCacheResult(attachmentFiles: Array(attachmentsGroupedBySHA256WithPathExtension.values))))
            }
            catch let error {
                assertionFailure(error.localizedDescription)
                complete(.failure(error))
            }
        }
    }
    
    func getResources(complete: @escaping ((_ resources: [ResourceModel]) -> Void)) {
        realmDatabase.background { (realm: Realm) in
            let realmResources: [RealmResource] = Array(realm.objects(RealmResource.self))
            let resources: [ResourceModel] = realmResources.map({ResourceModel(realmResource: $0)})
            DispatchQueue.main.async {
                complete(resources)
            }
        }
    }
    
    func getResource(id: String, complete: @escaping ((_ resource: ResourceModel?) -> Void)) {
        realmDatabase.background { (realm: Realm) in
            let resource: ResourceModel?
            
            if let realmResource = realm.object(ofType: RealmResource.self, forPrimaryKey: id) {
                resource = ResourceModel(realmResource: realmResource)
            }
            else {
                resource = nil
            }
            DispatchQueue.main.async {
                complete(resource)
            }
        }
    }
    
    func getResourceLanguage(resourceId: String, languageId: String, complete: @escaping ((_ language: LanguageModel?) -> Void)) {
        realmDatabase.background { (realm: Realm) in
            var language: LanguageModel?
            if let realmResource = realm.object(ofType: RealmResource.self, forPrimaryKey: resourceId) {
                if let realmLanguage = realmResource.languages.filter("id = '\(languageId)'").first {
                    language = LanguageModel(realmLanguage: realmLanguage)
                }
            }
            DispatchQueue.main.async {
                complete(language)
            }
        }
    }
    
    func getLanguages(complete: @escaping ((_ languages: [LanguageModel]) -> Void)) {
        realmDatabase.background { (realm: Realm) in
            let realmLanguages: [RealmLanguage] = Array(realm.objects(RealmLanguage.self))
            let languages: [LanguageModel] = realmLanguages.map({LanguageModel(realmLanguage: $0)})
            DispatchQueue.main.async {
                complete(languages)
            }
        }
    }
    
    func getLanguage(id: String, complete: @escaping ((_ language: LanguageModel?) -> Void)) {
        realmDatabase.background { (realm: Realm) in
            let language: LanguageModel?
            
            if let realmLanguage = realm.object(ofType: RealmLanguage.self, forPrimaryKey: id) {
                language = LanguageModel(realmLanguage: realmLanguage)
            }
            else {
                language = nil
            }
            DispatchQueue.main.async {
                complete(language)
            }
        }
    }
    
    func getAttachment(id: String) -> RealmAttachment? {
        // TODO: Get RealmAttachment and map to AttachmentModel.
        return nil//mainThreadRealm.object(ofType: RealmAttachment.self, forPrimaryKey: id)
    }
    
    func getTranslation(id: String) -> RealmTranslation? {
        // TODO: Get RealmTranslation and map to TranslationModel.
        return nil//mainThreadRealm.object(ofType: RealmTranslation.self, forPrimaryKey: id)
    }
}
