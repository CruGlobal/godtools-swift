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

class DownloadedResourceManager: GTDataManager {
    static let shared = DownloadedResourceManager()
    
    let path = "/resources"
    
    var resources = [DownloadedResource]()
    
    override init() {
        super.init()
        serializer.registerResource(DownloadedResourceJson.self)
        serializer.registerResource(TranslationResource.self)
        serializer.registerResource(PageResource.self)
        serializer.registerResource(LanguageResource.self)
    }
    
    func loadFromDisk() -> [DownloadedResource] {
        resources = DownloadedResource.mr_findAll() as! [DownloadedResource]
        return resources
    }
    
    func loadFromRemote() -> Promise<[DownloadedResource]> {
        showNetworkingIndicator()
        
        let params = ["include": "translations,pages"]
        
        return issueGETRequest(params)
            .then { data -> Promise<[DownloadedResource]> in
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
            let cachedResource = DownloadedResource.mr_findFirstOrCreate(byAttribute: "remoteId",
                                                                         withValue: remoteResource.id!,
                                                                         in: self.context)
            
            cachedResource.code = remoteResource.abbreviation
            cachedResource.name = remoteResource.name
            cachedResource.copyrightDescription = remoteResource.copyrightDescription
            cachedResource.totalViews = remoteResource.totalViews!.int32Value
            
            let remoteTranslations = remoteResource.latestTranslations!
            for remoteTranslationGeneric in remoteTranslations {
                let remoteTranslation = remoteTranslationGeneric as! TranslationResource
                let languageId = remoteTranslation.language?.id ?? "-1"
                let resourceId = remoteResource.id ?? "-1"
                let version = remoteTranslation.version!.int16Value
                
                if !translationShouldBeSaved(languageId: languageId, resourceId: resourceId, version: version) {
                    continue;
                }
                
                let cachedTranslation = Translation.mr_findFirstOrCreate(byAttribute: "remoteId",
                                                                         withValue: remoteTranslation.id!,
                                                                         in: self.context)
                
                cachedTranslation.language = LanguagesManager.shared.loadFromDisk(id: languageId)
                cachedTranslation.version = remoteTranslation.version!.int16Value
                cachedTranslation.isPublished = remoteTranslation.isPublished!.boolValue
                cachedTranslation.manifestFilename = remoteTranslation.manifestName
                
                cachedResource.addToTranslations(cachedTranslation)
                
                TranslationsManager.shared.purgeTranslationsOlderThan(cachedTranslation, saving: false)
            }
            
            let remotePages = remoteResource.pages!
            for remotePageGeneric in remotePages {
                let remotePage = remotePageGeneric as! PageResource
                
                let cachedPage = PageFile.mr_findFirstOrCreate(byAttribute: "remoteId",
                                                               withValue: remotePage.id!,
                                                               in: self.context)
                
                cachedPage.filename = remotePage.filename
                cachedPage.resource = cachedResource
            }
        }
        
        saveToDisk()
    }
    
    private func translationShouldBeSaved(languageId: String, resourceId: String, version: Int16) -> Bool {        
        let predicate = NSPredicate(format: "language.remoteId = %@ AND downloadedResource.remoteId = %@",
                                    languageId,
                                    resourceId)
        
        guard let existingTranslations: [Translation] = Translation.mr_findAll(with: predicate,
                                                                               in: self.context) as? [Translation] else {
            // default to saving if in doubt.
            return true
        }
        
        let latestTranslation = existingTranslations.max(by: {$0.version < $1.version})
        
        return latestTranslation == nil || version > latestTranslation!.version
    }
    
    override func buildURLString() -> String {
        return "\(GTConstants.kApiBase)/\(self.path)"
    }
}
