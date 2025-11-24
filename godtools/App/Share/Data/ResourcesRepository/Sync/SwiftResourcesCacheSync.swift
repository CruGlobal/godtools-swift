//
//  SwiftResourcesCacheSync.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine
import SwiftData

@available(iOS 17.4, *)
class SwiftResourcesCacheSync {
    
    typealias SHA256PlusPathExtension = String
    typealias ResourceId = String
    typealias TranslationId = String
    
    private let swiftDatabase: SwiftDatabase
    private let trackDownloadedTranslationsRepository: TrackDownloadedTranslationsRepository
    
    init(swiftDatabase: SwiftDatabase, trackDownloadedTranslationsRepository: TrackDownloadedTranslationsRepository) {
        
        self.swiftDatabase = swiftDatabase
        self.trackDownloadedTranslationsRepository = trackDownloadedTranslationsRepository
    }
    
    func syncResources(resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsCodable, shouldRemoveDataThatNoLongerExists: Bool) -> AnyPublisher<ResourcesCacheSyncResult, Error> {
     
        return Future() { promise in
            
            let swiftDatabase: SwiftDatabase = self.swiftDatabase
            
            let context = swiftDatabase.openContext()
            
            var newObjectsToStore: [any PersistentModel] = Array()
            
            var resourcesDictionary: [ResourceId: SwiftResource] = Dictionary()
            var translationsDictionary: [TranslationId: SwiftTranslation] = Dictionary()
                            
            // sync new resourecs
            
            var existingResourcesMinusNewlyAddedResources: [SwiftResource]
            
            if shouldRemoveDataThatNoLongerExists {
                let allResources: [SwiftResource] = swiftDatabase.getObjects(context: context, query: nil)
                existingResourcesMinusNewlyAddedResources = allResources
            }
            else {
                existingResourcesMinusNewlyAddedResources = Array()
            }
            
            if !resourcesPlusLatestTranslationsAndAttachments.resources.isEmpty {
                
                for newResource in resourcesPlusLatestTranslationsAndAttachments.resources {
                    
                    let resource = SwiftResource.createNewFrom(interface: newResource)
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
            
            var existingTranslationsMinusNewlyAddedTranslations: [SwiftTranslation]
            
            if shouldRemoveDataThatNoLongerExists {
                let allTranslations: [SwiftTranslation] = swiftDatabase.getObjects(context: context, query: nil)
                existingTranslationsMinusNewlyAddedTranslations = allTranslations
            }
            else {
                existingTranslationsMinusNewlyAddedTranslations = Array()
            }
            
            if !resourcesPlusLatestTranslationsAndAttachments.translations.isEmpty {
                
                for newTranslation in resourcesPlusLatestTranslationsAndAttachments.translations {
                    
                    let translation = SwiftTranslation.createNewFrom(interface: newTranslation)
                    
                    if let resourceId = newTranslation.resource?.id {
                        translation.resource = resourcesDictionary[resourceId]
                    }
                    
                    if let languageId = newTranslation.language?.id {
                        translation.language = swiftDatabase.getObject(context: context, id: languageId)
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
            
            var existingAttachmentsMinusNewlyAddedAttachments: [SwiftAttachment]
            
            if shouldRemoveDataThatNoLongerExists {
                let allAttachments: [SwiftAttachment] = swiftDatabase.getObjects(context: context, query: nil)
                existingAttachmentsMinusNewlyAddedAttachments = allAttachments
            }
            else {
                existingAttachmentsMinusNewlyAddedAttachments = Array()
            }
            
            if !resourcesPlusLatestTranslationsAndAttachments.attachments.isEmpty {
                
                for newAttachment in resourcesPlusLatestTranslationsAndAttachments.attachments {
                    
                    let attachment = SwiftAttachment.createNewFrom(interface: newAttachment)
                    
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
            
            for ( _, resource) in resourcesDictionary {
                
                for variantId in resource.getVariantIds() {
                    
                    guard let variant = resourcesDictionary[variantId] else {
                        continue
                    }
                    
                    resource.addVariant(variant: variant)
                }
                
                if let defaultVarientId = resource.defaultVariantId, let defaultVariant = resourcesDictionary[defaultVarientId] {
                    
                    resource.setDefaultVariant(variant: defaultVariant)
                }
                
                for translationId in resource.getLatestTranslationIds() {
                    
                    guard let translation = translationsDictionary[translationId] else {
                        continue
                    }
                    
                    resource.addLatestTranslation(translation: translation)
                    
                    if let language = translation.language {
                        resource.addLanguage(language: language)
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
                
                let latestTrackedDownloadedTranslation: DownloadedTranslationDataModel? = self.trackDownloadedTranslationsRepository.getLatestDownloadedTranslation(resourceId: resourceId, languageId: languageId)
                
                let translationIsLatestDownloadedTranslation: Bool = latestTrackedDownloadedTranslation?.translationId == $0.id
                
                if translationIsLatestDownloadedTranslation {
                    
                    return false
                }
                
                return true
            })
            
            //
            
            let translationIdsToRemove: [String] = existingTranslationsMinusNewlyAddedTranslations.map({$0.id})
            let downloadedTranslationsToRemove: [SwiftDownloadedTranslation] = swiftDatabase.getObjects(context: context, ids: translationIdsToRemove)

            let resourcesRemoved: [ResourceDataModel] = existingResourcesMinusNewlyAddedResources.map({ResourceDataModel(interface: $0)})
            let translationsRemoved: [TranslationDataModel] = existingTranslationsMinusNewlyAddedTranslations.map({TranslationDataModel(interface: $0)})
            let attachmentsRemoved: [AttachmentDataModel] = existingAttachmentsMinusNewlyAddedAttachments.map({AttachmentDataModel(interface: $0, storedAttachment: nil)})
            let downloadedTranslationsRemoved: [DownloadedTranslationDataModel] = downloadedTranslationsToRemove.map({DownloadedTranslationDataModel(model: $0)})
            
            // delete realm objects that no longer exist
            var objectsToRemove: [any PersistentModel] = Array()
                            
            objectsToRemove.append(contentsOf: existingResourcesMinusNewlyAddedResources)
            objectsToRemove.append(contentsOf: existingTranslationsMinusNewlyAddedTranslations)
            objectsToRemove.append(contentsOf: existingAttachmentsMinusNewlyAddedAttachments)
            objectsToRemove.append(contentsOf: downloadedTranslationsToRemove)
            
            do {
                
                try swiftDatabase.saveObjects(
                    context: context,
                    objectsToAdd: newObjectsToStore,
                    objectsToRemove: objectsToRemove
                )
                
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
        .eraseToAnyPublisher()
    }
}
