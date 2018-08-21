//
//  DownloadedResourceJson.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SwiftyJSON

class DownloadedResourceJson {
    
    var id = ""
    var name = ""
    var descr = ""
    var abbreviation = ""
    var copyrightDescription = ""
    var bannerId = ""
    var aboutBannerId = ""
    var totalViews = NSNumber(integerLiteral: 0)
    
    var latestTranslations: [TranslationResource]?
    var translations: [TranslationResource]?
    var pages: [Any]?
    var attachments: [Any]?
    
    static func initializeFrom(data: Data) -> [DownloadedResourceJson] {
        var resources = [DownloadedResourceJson]();
        
        let json = JSON(data: data)
        let jsonData = json["data"]
        let jsonIncluded = json["included"]
        
        for resource in jsonData.arrayValue {
            let downloadedResource = DownloadedResourceJson();
            
            if let id = resource["id"].string {
                downloadedResource.id = id
            }
            if let name = resource["name"].string {
                downloadedResource.name = name
            }
            if let descr = resource["descr"].string {
                downloadedResource.descr = descr
            }
            if let abbreviation = resource["abbreviation"].string {
                downloadedResource.abbreviation = abbreviation
            }
            if let copyrightDescription = resource["copyrightDescription"].string {
                downloadedResource.copyrightDescription = copyrightDescription
            }
            if let bannerId = resource["bannerId"].string {
                downloadedResource.bannerId = bannerId
            }
            if let aboutBannerId = resource["aboutBannerId"].string {
                downloadedResource.aboutBannerId = aboutBannerId
            }
            if let totalViews = resource["totalViews"].number {
                downloadedResource.totalViews = totalViews
            }
            
            downloadedResource.latestTranslations = TranslationResource.initializeFrom(json: jsonIncluded, resourceID: downloadedResource.id)
            resources.append(downloadedResource);
        }
        
        return resources;
    }
}
