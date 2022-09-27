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
    private let translationsRepository: TranslationsRepository
    
    required init(realmDatabase: RealmDatabase, translationsRepository: TranslationsRepository) {
        
        self.realmDatabase = realmDatabase
        self.translationsRepository = translationsRepository
    }
    
    func syncResources(languagesSyncResult: RealmLanguagesCacheSyncResult, resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel) -> AnyPublisher<RealmResourcesCacheSyncResult, Error> {
             
        return Future() { promise in

            self.realmDatabase.background { (realm: Realm) in
                
                var newRealmObjectsToStore: [Object] = Array()
                
                var realmResourcesDictionary: [ResourceId: RealmResource] = Dictionary()
                var realmTranslationsDictionary: [TranslationId: RealmTranslation] = Dictionary()
                
                var attachmentsGroupedBySHA256WithPathExtension: [SHA256PlusPathExtension: AttachmentFile] = Dictionary()
                
                // sync new resourecs
                
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
                
                // sync new translations
                
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
                
                // sync new attachments
                
                var existingAttachmentsMinusNewlyAddedAttachments: [RealmAttachment] = Array(realm.objects(RealmAttachment.self))
                
                if !resourcesPlusLatestTranslationsAndAttachments.attachments.isEmpty {
                    
                    for newAttachment in resourcesPlusLatestTranslationsAndAttachments.attachments {
                        
                        let realmAttachment = RealmAttachment()
                        realmAttachment.mapFrom(model: newAttachment)
                        
                        if let resourceId = newAttachment.resource?.id {
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
                        
                        if let indexOfNewAttachment = existingAttachmentsMinusNewlyAddedAttachments.firstIndex(where: { $0.id == newAttachment.id }) {
                            
                            existingAttachmentsMinusNewlyAddedAttachments.remove(at: indexOfNewAttachment)
                        }
                    }
                }
                else {
                    
                    existingAttachmentsMinusNewlyAddedAttachments = []
                }
                
                // attach latest translations and attach languages to newly added resources
                
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
                
                // filter latest downloaded translations from translations to delete
                
                existingTranslationsMinusNewlyAddedTranslations = existingTranslationsMinusNewlyAddedTranslations.filter({
                                        
                    guard let resourceId = $0.resource?.id else {
                        return true
                    }
                    
                    guard let languageId = $0.language?.id else {
                        return true
                    }
                    
                    let latestDownloadedTranslation: TranslationModel? = self.translationsRepository.getLatestDownloadedTranslation(resourceId: resourceId, languageId: languageId)
                    
                    let translationIsLatestDownloadedTranslation: Bool = latestDownloadedTranslation?.id == $0.id
                    
                    if translationIsLatestDownloadedTranslation {
                        
                        return false
                    }
                    
                    return true
                })
                
                //
                
                let translationIdsToRemove: [String] = existingTranslationsMinusNewlyAddedTranslations.map({$0.id})
                let downloadedTranslationsToRemove: [RealmDownloadedTranslation] = Array(realm.objects(RealmDownloadedTranslation.self).filter("\(#keyPath(RealmDownloadedTranslation.translationId)) IN %@", translationIdsToRemove))

                let resourcesRemoved: [ResourceModel] = existingResourcesMinusNewlyAddedResources.map({ResourceModel(model: $0)})
                let translationsRemoved: [TranslationModel] = existingTranslationsMinusNewlyAddedTranslations.map({TranslationModel(model: $0)})
                let attachmentsRemoved: [AttachmentModel] = existingAttachmentsMinusNewlyAddedAttachments.map({AttachmentModel(model: $0)})
                let downloadedTranslationsRemoved: [DownloadedTranslationDataModel] = downloadedTranslationsToRemove.map({DownloadedTranslationDataModel(model: $0)})
                
                // delete realm objects that no longer exist
                var realmObjectsToRemove: [Object] = Array()
                                
                realmObjectsToRemove.append(contentsOf: existingResourcesMinusNewlyAddedResources)
                realmObjectsToRemove.append(contentsOf: existingTranslationsMinusNewlyAddedTranslations)
                realmObjectsToRemove.append(contentsOf: existingAttachmentsMinusNewlyAddedAttachments)
                realmObjectsToRemove.append(contentsOf: downloadedTranslationsToRemove)
                
                do {
                    
                    try realm.write {
                        realm.add(newRealmObjectsToStore, update: .all)
                        realm.delete(realmObjectsToRemove)
                    }
                    
                    let syncResult = RealmResourcesCacheSyncResult(
                        languagesSyncResult: languagesSyncResult,
                        resourcesRemoved: resourcesRemoved,
                        translationsRemoved: translationsRemoved,
                        attachmentsRemoved: attachmentsRemoved,
                        latestAttachmentFiles: Array(attachmentsGroupedBySHA256WithPathExtension.values),
                        downloadedTranslationsRemoved: downloadedTranslationsRemoved
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
