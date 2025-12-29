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
    
    private let realmDatabase: LegacyRealmDatabase
    private let trackDownloadedTranslationsRepository: TrackDownloadedTranslationsRepository
    
    init(realmDatabase: LegacyRealmDatabase, trackDownloadedTranslationsRepository: TrackDownloadedTranslationsRepository) {
        
        self.realmDatabase = realmDatabase
        self.trackDownloadedTranslationsRepository = trackDownloadedTranslationsRepository
    }
    
    func syncResources(resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsCodable, shouldRemoveDataThatNoLongerExists: Bool) -> AnyPublisher<ResourcesCacheSyncResult, Error> {
             
        return Future() { promise in

            self.realmDatabase.background { (realm: Realm) in
                
                var newObjectsToStore: [Object] = Array()
                
                var resourcesDictionary: [ResourceId: RealmResource] = Dictionary()
                var translationsDictionary: [TranslationId: RealmTranslation] = Dictionary()
                                
                // sync new resourecs
                
                var existingResourcesMinusNewlyAddedResources: [RealmResource]
                
                if shouldRemoveDataThatNoLongerExists {
                    existingResourcesMinusNewlyAddedResources = Array(realm.objects(RealmResource.self))
                }
                else {
                    existingResourcesMinusNewlyAddedResources = Array()
                }
                
                if !resourcesPlusLatestTranslationsAndAttachments.resources.isEmpty {
                    
                    for newResource in resourcesPlusLatestTranslationsAndAttachments.resources {
                        
                        let resource = RealmResource.createNewFrom(interface: newResource)
                        resourcesDictionary[resource.id] = resource
                        
                        newObjectsToStore.append(resource)
                        
                        if let index = existingResourcesMinusNewlyAddedResources.firstIndex(where: { $0.id == newResource.id }) {
                            
                            existingResourcesMinusNewlyAddedResources.remove(at: index)
                        }
                    }
                }
                else {
                    
                    existingResourcesMinusNewlyAddedResources = []
                }
                
                // sync new translations
                
                var existingTranslationsMinusNewlyAddedTranslations: [RealmTranslation]
                
                if shouldRemoveDataThatNoLongerExists {
                    existingTranslationsMinusNewlyAddedTranslations = Array(realm.objects(RealmTranslation.self))
                }
                else {
                    existingTranslationsMinusNewlyAddedTranslations = Array()
                }
                
                if !resourcesPlusLatestTranslationsAndAttachments.translations.isEmpty {
                    
                    for newTranslation in resourcesPlusLatestTranslationsAndAttachments.translations {
                        
                        let translation = RealmTranslation.createNewFrom(interface: newTranslation)
                        
                        if let resourceId = newTranslation.resource?.id {
                            translation.resource = resourcesDictionary[resourceId]
                        }
                        
                        if let languageId = newTranslation.language?.id {
                            translation.language = realm.object(ofType: RealmLanguage.self, forPrimaryKey: languageId)
                        }
                        
                        translationsDictionary[translation.id] = translation
                        
                        newObjectsToStore.append(translation)
                        
                        if let indexOfNewTranslation = existingTranslationsMinusNewlyAddedTranslations.firstIndex(where: { $0.id == newTranslation.id }) {
                            
                            existingTranslationsMinusNewlyAddedTranslations.remove(at: indexOfNewTranslation)
                        }
                    }
                }
                else {
                    
                    existingTranslationsMinusNewlyAddedTranslations = []
                }
                
                // sync new attachments
                
                var existingAttachmentsMinusNewlyAddedAttachments: [RealmAttachment]
                
                if shouldRemoveDataThatNoLongerExists {
                    existingAttachmentsMinusNewlyAddedAttachments = Array(realm.objects(RealmAttachment.self))
                }
                else {
                    existingAttachmentsMinusNewlyAddedAttachments = Array()
                }
                
                if !resourcesPlusLatestTranslationsAndAttachments.attachments.isEmpty {
                    
                    for newAttachment in resourcesPlusLatestTranslationsAndAttachments.attachments {
                        
                        let attachment = RealmAttachment.createNewFrom(interface: newAttachment)
                        
                        if let resourceId = newAttachment.resource?.id {
                            attachment.resource = resourcesDictionary[resourceId]
                        }
                        
                        newObjectsToStore.append(attachment)
                        
                        if let indexOfNewAttachment = existingAttachmentsMinusNewlyAddedAttachments.firstIndex(where: { $0.id == newAttachment.id }) {
                            
                            existingAttachmentsMinusNewlyAddedAttachments.remove(at: indexOfNewAttachment)
                        }
                    }
                }
                else {
                    
                    existingAttachmentsMinusNewlyAddedAttachments = []
                }
                
                // attach variants and default variant, added variants will backlink to metatool
                // attach latest translations and attach languages to newly added resources
                
                for ( _, realmResource) in resourcesDictionary {
                    
                    for variantId in realmResource.getVariantIds() {
                        
                        guard let variant = resourcesDictionary[variantId] else {
                            continue
                        }
                        
                        realmResource.addVariant(variant: variant)
                    }
                    
                    if let defaultVarientId = realmResource.defaultVariantId, let defaultVariant = resourcesDictionary[defaultVarientId] {
                        
                        realmResource.setDefaultVariant(variant: defaultVariant)
                    }
                    
                    for translationId in realmResource.getLatestTranslationIds() {
                        
                        guard let realmTranslation = translationsDictionary[translationId] else {
                            continue
                        }
                        
                        realmResource.addLatestTranslation(translation: realmTranslation)
                        
                        if let realmLanguage = realmTranslation.language {
                            realmResource.addLanguage(language: realmLanguage)
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
                    
                    let latestTrackedDownloadedTranslation: DownloadedTranslationDataModel? = self.trackDownloadedTranslationsRepository.cache.getLatestDownloadedTranslation(resourceId: resourceId, languageId: languageId)
                    
                    let translationIsLatestDownloadedTranslation: Bool = latestTrackedDownloadedTranslation?.translationId == $0.id
                    
                    if translationIsLatestDownloadedTranslation {
                        
                        return false
                    }
                    
                    return true
                })
                
                //
                
                let translationIdsToRemove: [String] = existingTranslationsMinusNewlyAddedTranslations.map({$0.id})
                let downloadedTranslationsToRemove: [RealmDownloadedTranslation] = Array(realm.objects(RealmDownloadedTranslation.self).filter("\(#keyPath(RealmDownloadedTranslation.translationId)) IN %@", translationIdsToRemove))

                let resourcesRemoved: [ResourceDataModel] = existingResourcesMinusNewlyAddedResources.map({ResourceDataModel(interface: $0)})
                let translationsRemoved: [TranslationDataModel] = existingTranslationsMinusNewlyAddedTranslations.map({TranslationDataModel(interface: $0)})
                let attachmentsRemoved: [AttachmentDataModel] = existingAttachmentsMinusNewlyAddedAttachments.map({AttachmentDataModel(interface: $0, storedAttachment: nil)})
                let downloadedTranslationsRemoved: [DownloadedTranslationDataModel] = downloadedTranslationsToRemove.map({DownloadedTranslationDataModel(interface: $0)})
                
                // delete realm objects that no longer exist
                var objectsToRemove: [Object] = Array()
                                
                objectsToRemove.append(contentsOf: existingResourcesMinusNewlyAddedResources)
                objectsToRemove.append(contentsOf: existingTranslationsMinusNewlyAddedTranslations)
                objectsToRemove.append(contentsOf: existingAttachmentsMinusNewlyAddedAttachments)
                objectsToRemove.append(contentsOf: downloadedTranslationsToRemove)
                
                do {
                    
                    try realm.write {
                        realm.add(newObjectsToStore, update: .all)
                        realm.delete(objectsToRemove)
                    }
                    
                    let syncResult = ResourcesCacheSyncResult(
                        resourcesRemoved: resourcesRemoved,
                        translationsRemoved: translationsRemoved,
                        attachmentsRemoved: attachmentsRemoved,
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
