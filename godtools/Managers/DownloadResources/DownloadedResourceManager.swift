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
import MagicalRecord
import RealmSwift
class DownloadedResourceManager: GTDataManager {
    static let shared = DownloadedResourceManager()
    
    let path = "/resources"
    
    var resources: Results<DownloadedResource>
    
    override init() {
        super.init()
        serializer.registerResource(DownloadedResourceJson.self)
        serializer.registerResource(TranslationResource.self)
        serializer.registerResource(PageResource.self)
        serializer.registerResource(LanguageResource.self)
        serializer.registerResource(AttachmentResource.self)
    }
    
    func loadFromDisk() -> Results<DownloadedResource> {
        resources = findAllEntities(DownloadedResource.self)
        return resources
    }
    
    func loadFromRemote() -> Promise<Results<DownloadedResource>> {
        showNetworkingIndicator()
        
        let params = ["include": "translations,ages,attachments"]
        
        return issueGETRequest(params)
            .then { data -> Promise<Results<DownloadedResource>> in
                do {
                    let remoteResources = try self.serializer.deserializeData(data).data as! [DownloadedResourceJson]
                    
                    self.saveToDisk(remoteResources)
                } catch {
                    return Promise(error: error)
                }
                return Promise(value:self.loadFromDisk())
            }
    }
    
    private func saveToDisk(_ resources: [DownloadedResourceJson]) {
        for remoteResource in resources {
            let cachedResource = findFirstOrCreateEntity(DownloadedResource.self,
                                                         byAttribute: "remoteId",
                                                         withValue: remoteResource.id!)
            
            cachedResource.code = remoteResource.abbreviation!
            cachedResource.name = remoteResource.name!
            cachedResource.copyrightDescription = remoteResource.copyrightDescription
            cachedResource.bannerRemoteId = remoteResource.bannerId
            cachedResource.totalViews = remoteResource.totalViews!.int32Value
            
            for remoteAttachment in (remoteResource.attachments!) {
                let remoteAttachment = remoteAttachment as! AttachmentResource
                let cachedAttachment = findFirstOrCreateEntity(Attachment.self,
                                                               byAttribute: "remoteId",
                                                               withValue: remoteAttachment.id!)
                
                cachedAttachment.sha = remoteAttachment.sha256
                cachedAttachment.resource = cachedResource
            }
            
            if cachedResource.bannerRemoteId != nil {
                _ = BannerManager.shared.downloadFor(cachedResource)
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
                
                let cachedTranslation = findFirstOrCreateEntity(Translation.self,byAttribute: "remoteId",withValue: remoteTranslation.id!)
                
                cachedTranslation.language = LanguagesManager.shared.loadFromDisk(id: languageId)
                cachedTranslation.version = remoteTranslation.version!.int16Value
                cachedTranslation.isPublished = remoteTranslation.isPublished!.boolValue
                cachedTranslation.manifestFilename = remoteTranslation.manifestName
                cachedTranslation.localizedName = remoteTranslation.translatedName
                cachedTranslation.localizedDescription = remoteTranslation.translatedDescription
                                
                cachedResource.addToTranslations(cachedTranslation)
                
                TranslationsManager.shared.purgeTranslationsOlderThan(cachedTranslation, saving: false)
            }
        }
        
        saveToDisk()
    }

    private func translationShouldBeSaved(languageId: String, resourceId: String, version: Int16) -> Bool {        
        let predicate = NSPredicate(format: "language.remoteId = %@ AND downloadedResource.remoteId = %@",
                                    languageId,
                                    resourceId)
        
        let existingTranslations: [Translation] = findEntities(Translation.self, matching: predicate)
        
        let latestTranslation = existingTranslations.max(by: {$0.version < $1.version})
        
        return latestTranslation == nil || version > latestTranslation!.version
    }
    
    override func buildURL() -> URL? {
        return Config.shared().baseUrl?
                              .appendingPathComponent(self.path)
    }
}
