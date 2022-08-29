//
//  RealmResourcesCacheSync.swift
//  godtools
//
//  Created by Levi Eggert on 7/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmResourcesCacheSync {
    
    typealias SHA256PlusPathExtension = String
    typealias ResourceId = String
    typealias TranslationId = String
    
    private let realmDatabase: RealmDatabase
    
    required init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func syncResources(languagesSyncResult: RealmLanguagesCacheSyncResult, resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel) -> AnyPublisher<RealmResourcesCacheSyncResult, Error> {
             
        return Future() { promise in

            self.realmDatabase.background { (realm: Realm) in
                
                var realmResourcesDictionary: [ResourceId: RealmResource] = Dictionary()
                var realmTranslationsDictionary: [TranslationId: RealmTranslation] = Dictionary()
                
                var attachmentsGroupedBySHA256WithPathExtension: [SHA256PlusPathExtension: AttachmentFile] = Dictionary()
                
                var realmObjectsToCache: [Object] = Array()
                
                // parse resources
                
                var resourceIdsRemoved: [String] = Array(realm.objects(RealmResource.self)).map({$0.id})
                
                if !resourcesPlusLatestTranslationsAndAttachments.resources.isEmpty {
                    
                    for resource in resourcesPlusLatestTranslationsAndAttachments.resources {
                        
                        let realmResource = RealmResource()
                        realmResource.mapFrom(model: resource)
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
                        realmTranslation.mapFrom(model: translation)
                        
                        if let resourceId = translation.resource?.id {
                            realmTranslation.resource = realmResourcesDictionary[resourceId]
                        }
                        
                        if let languageId = translation.language?.id {
                            realmTranslation.language = realm.object(ofType: RealmLanguage.self, forPrimaryKey: languageId)
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
                
                let resourcesToRemove: [RealmResource] = Array(realm.objects(RealmResource.self).filter("id IN %@", resourceIdsRemoved))
                let translationsToRemove: [RealmTranslation] = Array(realm.objects(RealmTranslation.self).filter("id IN %@", translationIdsRemoved))
                let attachmentsToRemove: [RealmAttachment] = Array(realm.objects(RealmAttachment.self).filter("id IN %@", attachmentIdsRemoved))
                
                realmObjectsToRemove.append(contentsOf: resourcesToRemove)
                // TODO: Will complete in GT-1413. ~Levi
                //realmObjectsToRemove.append(contentsOf: translationsToRemove)
                realmObjectsToRemove.append(contentsOf: attachmentsToRemove)

                do {
                    try realm.write {
                        realm.add(realmObjectsToCache, update: .all)
                        realm.delete(realmObjectsToRemove)
                    }
                    
                    let syncResult = RealmResourcesCacheSyncResult(
                        languagesSyncResult: languagesSyncResult,
                        resourceIdsRemoved: resourceIdsRemoved,
                        translationIdsRemoved: translationIdsRemoved,
                        attachmentIdsRemoved: attachmentIdsRemoved,
                        latestAttachmentFiles: Array(attachmentsGroupedBySHA256WithPathExtension.values)
                    )
                    
                    promise(.success(syncResult))
                }
                catch let error {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
