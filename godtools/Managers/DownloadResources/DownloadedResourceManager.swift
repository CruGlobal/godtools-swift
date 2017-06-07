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
    static let shared = DownloadedResourceManager()
    
    let path = "/resources"
    
    var resources = List<DownloadedResource>()
    
    override init() {
        super.init()
        serializer.registerResource(DownloadedResourceJson.self)
        serializer.registerResource(TranslationResource.self)
        serializer.registerResource(PageResource.self)
        serializer.registerResource(LanguageResource.self)
        serializer.registerResource(AttachmentResource.self)
    }
    
    func loadFromDisk() -> List<DownloadedResource> {
        resources = findAllEntities(DownloadedResource.self)
        return resources
    }
    
    func loadFromRemote() -> Promise<List<DownloadedResource>> {
        showNetworkingIndicator()
        
        let params = ["include": "translations,ages,attachments"]
        
        return issueGETRequest(params)
            .then { data -> Promise<List<DownloadedResource>> in
                do {
                    let remoteResources = try self.serializer.deserializeData(data).data as! [DownloadedResourceJson]
                    
                    self.saveToDisk(remoteResources)
                } catch {
                    return Promise(error: error)
                }
                return Promise(value:self.loadFromDisk())
            }
    }
    
    func download(_ resource: DownloadedResource) {
        do {
            try realm.write {
                resource.shouldDownload = true
                TranslationZipImporter.shared.download(resource: resource)
            }
        } catch {
            
        }
    }
    
    func delete(_ resource: DownloadedResource) {
        do {
            try realm.write {
                resource.shouldDownload = false
                for translation in resource.translations {
                    translation.isDownloaded = false
                    //translation.removeFromReferencedFiles(translation.referencedFiles!)
                }
                
                TranslationFileRemover().deleteUnusedPages()
            }
        } catch {
            
        }
    }
    
    private func saveToDisk(_ resources: [DownloadedResourceJson]) {
        try! realm.write {
            for remoteResource in resources {
                var cachedResource = findEntity(DownloadedResource.self, byAttribute: "remoteId", withValue: remoteResource.id!)
                
                if cachedResource == nil {
                    cachedResource = DownloadedResource()
                    cachedResource!.remoteId = remoteResource.id!
                    realm.add(cachedResource!)
                }
                
                cachedResource!.code = remoteResource.abbreviation!
                cachedResource!.name = remoteResource.name!
                cachedResource!.copyrightDescription = remoteResource.copyrightDescription
                cachedResource!.bannerRemoteId = remoteResource.bannerId
                cachedResource!.totalViews = remoteResource.totalViews!.int32Value
                
                for remoteAttachment in (remoteResource.attachments!) {
                    let remoteAttachment = remoteAttachment as! AttachmentResource
                    var cachedAttachment = findEntity(Attachment.self,
                                                      byAttribute: "remoteId",
                                                      withValue: remoteAttachment.id!)
                    
                    if cachedAttachment == nil {
                        cachedAttachment = Attachment()
                        cachedAttachment!.remoteId = remoteAttachment.id!
                        realm.add(cachedAttachment!)
                    }
                    
                    cachedAttachment!.sha = remoteAttachment.sha256
                    cachedAttachment!.resource = cachedResource
                }
                
                if cachedResource!.bannerRemoteId != nil {
                    _ = BannerManager.shared.downloadFor(cachedResource!)
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
                    
                    var cachedTranslation = findEntity(Translation.self,byAttribute: "remoteId",withValue: remoteTranslation.id!)
                    
                    if cachedTranslation == nil {
                        cachedTranslation = Translation()
                        cachedTranslation!.remoteId = remoteTranslation.id!
                        realm.add(cachedTranslation!)
                    }
                    
                    cachedTranslation!.version = remoteTranslation.version!.int16Value
                    cachedTranslation!.isPublished = remoteTranslation.isPublished!.boolValue
                    cachedTranslation!.manifestFilename = remoteTranslation.manifestName
                    cachedTranslation!.localizedName = remoteTranslation.translatedName
                    cachedTranslation!.localizedDescription = remoteTranslation.translatedDescription
                    
                    cachedTranslation!.downloadedResource = cachedResource
                    cachedResource!.translations.append(cachedTranslation!)
                    
                    let cachedLanguage = findEntity(Language.self, byAttribute: "remoteId", withValue: languageId)
                    cachedLanguage?.translations.append(cachedTranslation!)
                    cachedTranslation!.language = cachedLanguage
                    
                    //                TranslationsManager.shared.purgeTranslationsOlderThan(cachedTranslation, saving: false)
                }
            }
        }
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
