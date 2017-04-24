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
    }
    
    func loadFromDisk() -> Promise<[DownloadedResource]> {
        resources = DownloadedResource.mr_findAll() as! [DownloadedResource]
        return Promise(value: resources)
    }
    
    func loadFromRemote() -> Promise<[DownloadedResource]> {
        showNetworkingIndicator()
        
        // load all resources and save them to disk
        return issueGETRequest(["include" : "translations,pages"])
            .then { data -> Promise<[DownloadedResource]> in
                do {
                    let remoteResources = try self.serializer.deserializeData(data).data as! [DownloadedResourceJson]
                    
                    self.saveToDisk(remoteResources)
                } catch {
                    return Promise(error: error)
                }
                return self.loadFromDisk()
            }
    }
    
    private func saveToDisk(_ resources: [DownloadedResourceJson]) {
        MagicalRecord.save(blockAndWait: { (context) in
            for remoteResource in resources {
                let cachedResource = DownloadedResource.mr_findFirstOrCreate(byAttribute: "remoteId", withValue: remoteResource.id!, in: context)
                
                cachedResource.code = remoteResource.abbreviation
                cachedResource.name = remoteResource.name
                
                let remoteTranslations = remoteResource.translations!
                for remoteTranslationGeneric in remoteTranslations {
                    let remoteTranslation = remoteTranslationGeneric as! TranslationResource
                    
                    let cachedTranslation = Translation.mr_findFirstOrCreate(byAttribute: "remoteId", withValue: remoteTranslation.id!, in: context)
                    
                    cachedTranslation.version = remoteTranslation.version!.int16Value
                    cachedTranslation.isPublished = remoteTranslation.isPublished!.boolValue
                    cachedResource.addToTranslations(cachedTranslation)
                }
                
                let remotePages = remoteResource.pages!
                for remotePageGeneric in remotePages {
                    let remotePage = remotePageGeneric as! PageResource
                    
                    let cachedPage = PageFile.mr_findFirstOrCreate(byAttribute: "remoteId", withValue: remotePage.id!, in: context)

                    cachedPage.filename = remotePage.filename
                    cachedPage.resource = cachedResource
                }
            }
        })
    }
    
    override func buildURLString() -> String {
        return "\(GTConstants.kApiBase)/\(self.path)"
    }
}

extension DownloadedResourceManager: UITableViewDelegate {
    
}

extension DownloadedResourceManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = resources[indexPath.row].name
        
        return cell
    }
}
