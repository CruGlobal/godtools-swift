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

class DownloadedResourceManager: NSObject {
    static let shared = DownloadedResourceManager()
    
    let path = "/resources"
    let serializer = Serializer()
    
    var resources = [DownloadedResource]()
    
    override init() {
        super.init()
        serializer.registerResource(DownloadedResourceJson.self)
        serializer.registerResource(TranslationResource.self)
    }
    
    func loadFromDisk() -> Promise<[DownloadedResource]> {
        resources = DownloadedResource.mr_findAll() as! [DownloadedResource]
        return Promise(value: resources)
    }
    
    func loadFromRemote() -> Promise<[DownloadedResource]> {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        return Alamofire.request(URL(string: "\(GTConstants.kApiBase)/\(path)")!).responseData().then { data -> Promise<[DownloadedResource]> in
            let jsonDocument = try! self.serializer.deserializeData(data)
            
            MagicalRecord.save(blockAndWait: { (context) in
                for element in jsonDocument.data! {
                    let resourceResource = element as! DownloadedResourceJson
                    let resource = DownloadedResource.mr_findFirstOrCreate(byAttribute: "remoteId", withValue: resourceResource.id!, in: context)
                    
                    resource.code = resourceResource.abbreviation
                    resource.name = resourceResource.name
                }
            })
            
            return self.loadFromDisk()
        }.then(execute: { (resources) -> Promise<[DownloadedResource]> in
            
            for resource in resources {
                _ = Alamofire.request(URL(string: "\(GTConstants.kApiBase)/\(self.path)/\(resource.remoteId!)")!).responseData().then { data -> Promise<Any> in
                    let jsonDocument = try! self.serializer.deserializeData(data).included as! [TranslationResource]
                    
                    for element in jsonDocument {
                        let translation = element as! TranslationResource
                        print(translation.isPublished?.boolValue, translation.version, separator: ", ", terminator: "\n")
                    }
                    return Promise(value: jsonDocument)
                }
            }
            return Promise(value: resources)
        })
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
