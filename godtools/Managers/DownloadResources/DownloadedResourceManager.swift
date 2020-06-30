//
//  DownloadedResourceManager.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import PromiseKit
import RealmSwift

class DownloadedResourceManager: GTDataManager {    
    
    func loadFromDisk() -> DownloadedResources {
        return findAllEntities(DownloadedResource.self)
    }
    
    func loadFromDisk(code: String) -> DownloadedResource? {
        return findEntity(DownloadedResource.self, byAttribute: "code", withValue: code)
    }
    
    func loadFromRemote() -> Promise<DownloadedResources> {
        
        let params:[String: Any] = ["include": "latest-translations,attachments"]

        let q = DispatchQueue.global(qos: .userInitiated)
        
        return issueGETRequest(params)
            .then(on:q) { data -> Promise<[DownloadedResourceJson]> in
                let remoteResources = JSONResourceFactory.initializeArrayFrom(data: data, type: DownloadedResourceJson.self)
                return .value(remoteResources)
            }
            .then { remoteResources -> Promise<[DownloadedResourceJson]> in
                self.saveToDisk(remoteResources)
                return .value(remoteResources)
            }
            .then { (_) -> Promise<DownloadedResources> in
                return .value(self.loadFromDisk())
            }
            .ensure {

        }
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
                guard let attachments = remoteResource.attachments else { continue }
                
                for remoteAttachment in attachments {
                    let cachedAttachment = save(remoteAttachment: remoteAttachment)
                    cachedAttachment.resource = cachedResource
                }
                
                if cachedResource.bannerRemoteId != nil || cachedResource.aboutBannerRemoteId != nil {
                    _ = BannerManager().downloadFor(cachedResource)
                }
                
                guard let remoteTranslations = remoteResource.latestTranslations else { continue }
                for remoteTranslation in remoteTranslations {
                    let languageId = remoteTranslation.languageId
                    let resourceId = remoteResource.id
                    let version = remoteTranslation.version.int16Value
                    
                    if translationShouldBeSaved(languageId: languageId, resourceId: resourceId, version: version) == false {
                        continue;
                    }
                    let cachedTranslation = save(remoteTranslation: remoteTranslation)
                    
                    cachedTranslation.downloadedResource = cachedResource
                    cachedResource.translations.append(cachedTranslation)
                    
                    guard let cachedLanguage = findEntityByRemoteId(Language.self, remoteId: languageId) else { continue }
                    cachedLanguage.translations.append(cachedTranslation)
                    cachedTranslation.language = cachedLanguage
                    
                    TranslationsManager().purgeTranslationsOlderThan(cachedTranslation)
                }
            }
        })
    }
    
    private func save(remoteResource: DownloadedResourceJson) -> DownloadedResource {
        var cachedResource: DownloadedResource
        
        if let alreadySavedResource = findEntityByRemoteId(DownloadedResource.self, remoteId: remoteResource.id) {
            cachedResource = alreadySavedResource
        } else {
            cachedResource = DownloadedResource()
            cachedResource.remoteId = remoteResource.id
            realm.add(cachedResource)
        }
        
        cachedResource.code = remoteResource.abbreviation
        cachedResource.descr = remoteResource.descr
        cachedResource.name = remoteResource.name
        cachedResource.toolType = remoteResource.toolType
        cachedResource.copyrightDescription = remoteResource.copyrightDescription
        cachedResource.bannerRemoteId = remoteResource.bannerId
        cachedResource.aboutBannerRemoteId = remoteResource.aboutBannerId
        cachedResource.totalViews = remoteResource.totalViews.int32Value
        cachedResource.aboutOverviewVideoYouTube = remoteResource.aboutOverviewVideoYouTube
        
        return cachedResource
    }
    
    private func save(remoteAttachment: AttachmentResource) -> Attachment {
        let alreadySavedAttachment = findEntityByRemoteId(Attachment.self, remoteId: remoteAttachment.id)
        
        var cachedAttachment: Attachment
        
        if alreadySavedAttachment == nil {
            cachedAttachment = Attachment()
            cachedAttachment.remoteId = remoteAttachment.id
            realm.add(cachedAttachment)
        } else {
            cachedAttachment = alreadySavedAttachment!
        }
        
        cachedAttachment.sha = remoteAttachment.sha256
        
        return cachedAttachment
    }
    
    private func save(remoteTranslation: TranslationResource) -> Translation {
        let alreadySavedTranslation = findEntityByRemoteId(Translation.self, remoteId: remoteTranslation.id)
        
        var cachedTranslation: Translation
        
        if alreadySavedTranslation == nil {
            cachedTranslation = Translation()
            cachedTranslation.remoteId = remoteTranslation.id
            realm.add(cachedTranslation)
        } else {
            cachedTranslation = alreadySavedTranslation!
        }
        
        cachedTranslation.version = remoteTranslation.version.int16Value
        cachedTranslation.isPublished = remoteTranslation.isPublished.boolValue
        cachedTranslation.manifestFilename = remoteTranslation.manifestName
        cachedTranslation.localizedName = remoteTranslation.translatedName
        cachedTranslation.localizedDescription = remoteTranslation.translatedDescription
        cachedTranslation.tagline = remoteTranslation.tagline
        
        return cachedTranslation
    }
    
    private func translationShouldBeSaved(languageId: String, resourceId: String, version: Int16) -> Bool {
        let predicate = NSPredicate(format: "language.remoteId = %@ AND downloadedResource.remoteId = %@",
                                    languageId,
                                    resourceId)
        
        let existingTranslations = findEntities(Translation.self, matching: predicate)
        
        guard let latestTranslation = existingTranslations.max(by: {$0.version < $1.version}) else { return true }
        
        return version > latestTranslation.version
    }
    
    override func buildURL() -> URL? {
        
        let baseUrl: String = AppConfig().mobileContentApiBaseUrl
        let path: String = "/resources"
        return URL(string: baseUrl + path)
    }
}
