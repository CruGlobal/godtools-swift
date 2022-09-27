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
                
                var newRealmObjectsToStore: [Object] = Array()
                
                var realmResourcesDictionary: [ResourceId: RealmResource] = Dictionary()
                var realmTranslationsDictionary: [TranslationId: RealmTranslation] = Dictionary()
                
                var attachmentsGroupedBySHA256WithPathExtension: [SHA256PlusPathExtension: AttachmentFile] = Dictionary()
                
                // parse resources
                
                var existingResourcesMinusNewlyAddedResources: [RealmResource] = Array(realm.objects(RealmResource.self))
                
                if !resourcesPlusLatestTranslationsAndAttachments.resources.isEmpty {
                    
                    for newResource in resourcesPlusLatestTranslationsAndAttachments.resources {
                        
                        let realmResource = RealmResource()
                        realmResource.mapFrom(model: newResource)
                        realmResourcesDictionary[realmResource.id] = realmResource
                        
                        newRealmObjectsToStore.append(realmResource)
                        
                        if let index = existingResourcesMinusNewlyAddedResources.firstIndex(where: { $0.id == newResource.id }) {
                            
                            existingResourcesMinusNewlyAddedResources.remove(at: index)
                        }
                    }
                }
                else {
                    
                    existingResourcesMinusNewlyAddedResources = []
                }
                
                // parse latest translations
                
                var existingTranslationsMinusNewlyAddedTranslations: [RealmTranslation] = Array(realm.objects(RealmTranslation.self))
                
                if !resourcesPlusLatestTranslationsAndAttachments.translations.isEmpty {
                    
                    for newTranslation in resourcesPlusLatestTranslationsAndAttachments.translations {
                        
                        let realmTranslation = RealmTranslation()
                        realmTranslation.mapFrom(model: newTranslation)
                        
                        if let resourceId = newTranslation.resource?.id {
                            realmTranslation.resource = realmResourcesDictionary[resourceId]
                        }
                        
                        if let languageId = newTranslation.language?.id {
                            realmTranslation.language = realm.object(ofType: RealmLanguage.self, forPrimaryKey: languageId)
                        }
                        
                        realmTranslationsDictionary[realmTranslation.id] = realmTranslation
                        
                        newRealmObjectsToStore.append(realmTranslation)
                        
                        if let indexOfNewTranslation = existingTranslationsMinusNewlyAddedTranslations.firstIndex(where: { $0.id == newTranslation.id }) {
                            
                            existingTranslationsMinusNewlyAddedTranslations.remove(at: indexOfNewTranslation)
                        }
                    }
                }
                else {
                    
                    existingTranslationsMinusNewlyAddedTranslations = []
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
                        
                        newRealmObjectsToStore.append(realmAttachment)
                        
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
                        
                        guard let realmTranslation = realmTranslationsDictionary[translationId] else {
                            continue
                        }
                        
                        if !realmResource.latestTranslations.contains(realmTranslation) {
                            realmResource.latestTranslations.append(realmTranslation)
                        }
                        
                        if let realmLanguage = realmTranslation.language, !realmResource.languages.contains(realmLanguage) {
                            realmResource.languages.append(realmLanguage)
                        }
                    }
                }
                
                let resourcesRemoved: [ResourceModel] = existingResourcesMinusNewlyAddedResources.map({ResourceModel(model: $0)})
                let translationsRemoved: [TranslationModel] = existingTranslationsMinusNewlyAddedTranslations.map({TranslationModel(model: $0)})
                
                // delete realm objects that no longer exist
                var realmObjectsToRemove: [Object] = Array()
                
                let attachmentsToRemove: [RealmAttachment] = Array(realm.objects(RealmAttachment.self).filter("id IN %@", attachmentIdsRemoved))
                
                realmObjectsToRemove.append(contentsOf: existingResourcesMinusNewlyAddedResources)
                realmObjectsToRemove.append(contentsOf: existingTranslationsMinusNewlyAddedTranslations)
                realmObjectsToRemove.append(contentsOf: attachmentsToRemove)

                do {
                    
                    try realm.write {
                        realm.add(newRealmObjectsToStore, update: .all)
                        realm.delete(realmObjectsToRemove)
                    }
                    
                    let syncResult = RealmResourcesCacheSyncResult(
                        languagesSyncResult: languagesSyncResult,
                        resourcesRemoved: resourcesRemoved,
                        translationsRemoved: translationsRemoved,
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
