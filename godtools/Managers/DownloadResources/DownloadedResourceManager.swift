//
//  DownloadedResourceManager.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import PromiseKit
import Spine
import RealmSwift

class DownloadedResourceManager: GTDataManager {    
    let path = "/resources"
    
    override init() {
        super.init()
        serializer.registerResource(DownloadedResourceJson.self)
        serializer.registerResource(TranslationResource.self)
        serializer.registerResource(LanguageResource.self)
        serializer.registerResource(AttachmentResource.self)
    }
    
    func loadFromDisk() -> DownloadedResources {
        return findAllEntities(DownloadedResource.self)

    }
    
    func loadFromRemote() -> Promise<DownloadedResources> {
        showNetworkingIndicator()
        
        let params = ["include": "translations,attachments"]
        
        return issueGETRequest(params)
            .then { data -> Promise<DownloadedResources> in
                do {
                    let remoteResources = try self.serializer.deserializeData(data).data as! [DownloadedResourceJson]
                    
                    self.saveToDisk(remoteResources)
                } catch {
                    return Promise(error: error)
                }
                return Promise(value:self.loadFromDisk())
            }
            .always {
                self.hideNetworkIndicator()
        }
    }
    
    func loadInitialContentFromDisk() {
        let resourcesPath = URL(fileURLWithPath:Bundle.main.path(forResource: "resources", ofType: "json")!)
        let resourcesData = try! Data(contentsOf: resourcesPath)
        let resourcesDeserialized = try! serializer.deserializeData(resourcesData).data as! [DownloadedResourceJson]
        
        saveToDisk(resourcesDeserialized)
    }
    
    func download(_ resource: DownloadedResource) {
        safelyWriteToRealm {
            resource.shouldDownload = true
            TranslationZipImporter().download(resource: resource)
        }
    }
    
    func delete(_ resource: DownloadedResource) {
        safelyWriteToRealm {
            resource.shouldDownload = false
            for translation in resource.translations {
                translation.isDownloaded = false
            }
            
            TranslationFileRemover().deleteUnusedPages()
        }
    }
    
    private func saveToDisk(_ resources: [DownloadedResourceJson]) {
        safelyWriteToRealm({
            for remoteResource in resources {
                let cachedResource = save(remoteResource: remoteResource)
                
                for remoteAttachment in (remoteResource.attachments!) {
                    let remoteAttachment = remoteAttachment as! AttachmentResource
                    let cachedAttachment = save(remoteAttachment: remoteAttachment)
                    cachedAttachment.resource = cachedResource
                }
                
                if cachedResource.bannerRemoteId != nil || cachedResource.aboutBannerRemoteId != nil {
                    _ = BannerManager().downloadFor(cachedResource)
                }
                
                let remoteTranslations = remoteResource.latestTranslations!
                for remoteTranslationGeneric in remoteTranslations {
                    let remoteTranslation = remoteTranslationGeneric as! TranslationResource
                    let languageId = remoteTranslation.language?.id ?? "-1"
                    let resourceId = remoteResource.id ?? "-1"
                    let version = remoteTranslation.version!.int16Value
                    
                    if !translationShouldBeSaved(languageId: languageId, resourceId: resourceId, version: version) {
                        continue;
                    }
                    let cachedTranslation = save(remoteTranslation: remoteTranslation)
                    
                    cachedTranslation.downloadedResource = cachedResource
                    cachedResource.translations.append(cachedTranslation)
                    
                    let cachedLanguage = findEntityByRemoteId(Language.self, remoteId: languageId)
                    cachedLanguage?.translations.append(cachedTranslation)
                    cachedTranslation.language = cachedLanguage
                    
                    TranslationsManager().purgeTranslationsOlderThan(cachedTranslation)
                }
            }
        })
    }
    
    private func save(remoteResource: DownloadedResourceJson) -> DownloadedResource {
        let alreadySavedResource = findEntityByRemoteId(DownloadedResource.self, remoteId: remoteResource.id!)
        
        var cachedResource: DownloadedResource
        
        if alreadySavedResource == nil {
            cachedResource = DownloadedResource()
            cachedResource.remoteId = remoteResource.id!
            realm.add(cachedResource)
        } else {
            cachedResource = alreadySavedResource!
        }
        
        cachedResource.code = remoteResource.abbreviation!
        cachedResource.descr = remoteResource.descr
        cachedResource.name = remoteResource.name!
        cachedResource.copyrightDescription = remoteResource.copyrightDescription
        cachedResource.bannerRemoteId = remoteResource.bannerId
        cachedResource.aboutBannerRemoteId = remoteResource.aboutBannerId
        cachedResource.totalViews = remoteResource.totalViews!.int32Value
        
        return cachedResource
    }
    
    private func save(remoteAttachment: AttachmentResource) -> Attachment {
        let alreadySavedAttachment = findEntityByRemoteId(Attachment.self, remoteId: remoteAttachment.id!)
        
        var cachedAttachment: Attachment
        
        if alreadySavedAttachment == nil {
            cachedAttachment = Attachment()
            cachedAttachment.remoteId = remoteAttachment.id!
            realm.add(cachedAttachment)
        } else {
            cachedAttachment = alreadySavedAttachment!
        }
        
        cachedAttachment.sha = remoteAttachment.sha256
        
        return cachedAttachment
    }
    
    private func save(remoteTranslation: TranslationResource) -> Translation {
        let alreadySavedTranslation = findEntityByRemoteId(Translation.self, remoteId: remoteTranslation.id!)
        
        var cachedTranslation: Translation
        
        if alreadySavedTranslation == nil {
            cachedTranslation = Translation()
            cachedTranslation.remoteId = remoteTranslation.id!
            realm.add(cachedTranslation)
        } else {
            cachedTranslation = alreadySavedTranslation!
        }
        
        cachedTranslation.version = remoteTranslation.version!.int16Value
        cachedTranslation.isPublished = remoteTranslation.isPublished!.boolValue
        cachedTranslation.manifestFilename = remoteTranslation.manifestName
        cachedTranslation.localizedName = remoteTranslation.translatedName
        cachedTranslation.localizedDescription = remoteTranslation.translatedDescription
        
        return cachedTranslation
    }
    
    private func translationShouldBeSaved(languageId: String, resourceId: String, version: Int16) -> Bool {
        let predicate = NSPredicate(format: "language.remoteId = %@ AND downloadedResource.remoteId = %@",
                                    languageId,
                                    resourceId)
        
        let existingTranslations = findEntities(Translation.self, matching: predicate)
        
        let latestTranslation = existingTranslations.max(by: {$0.version < $1.version})
        
        return latestTranslation == nil || version > latestTranslation!.version
    }
    
    override func buildURL() -> URL? {
        return Config.shared().baseUrl?
                              .appendingPathComponent(self.path)
    }
}
