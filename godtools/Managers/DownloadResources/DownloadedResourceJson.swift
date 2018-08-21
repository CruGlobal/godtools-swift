//
//  DownloadedResourceJson.swift
//  godtools
//
//  Created by Ryan Carlson on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import Spine
import SwiftyJSON

class DownloadedResourceJson: Resource {
    
    var id2 = ""
    var name: String?
    var descr: String?
    var abbreviation: String?
    var copyrightDescription: String?
    var bannerId: String?
    var aboutBannerId: String?
    var totalViews: NSNumber?
    
    var latestTranslations: LinkedResourceCollection?
    var translations: LinkedResourceCollection?
    var pages: LinkedResourceCollection?
    var attachments: LinkedResourceCollection?
    
    static func initializeFrom(data: Data) -> [DownloadedResourceJson] {
        var resources = [DownloadedResourceJson]();
        
        let json = JSON(data: data)["data"]
        
        for resource in json.arrayValue {
            let downloadedResource = DownloadedResourceJson();
            
            if let id2 = resource["id"].string {
                downloadedResource.id2 = id2
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
            
            resources.append(downloadedResource);
        }
        
        return resources;
    }
    
    override class var resourceType: ResourceType {
        return "resource"
    }
    
    override class var fields: [Field] {
        return fieldsFromDictionary([
            "name" : Attribute(),
            "descr": Attribute().serializeAs("description"),
            "abbreviation" : Attribute(),
            "translations" : ToManyRelationship(TranslationResource.self),
            "copyrightDescription": Attribute().serializeAs("attr-copyright"),
            "bannerId": Attribute().serializeAs("attr-banner"),
            "aboutBannerId": Attribute().serializeAs("attr-banner-about"),
            "totalViews": Attribute().serializeAs("total-views"),
            "latestTranslations" : ToManyRelationship(TranslationResource.self).serializeAs("latest-translations"),
            "attachments": ToManyRelationship(AttachmentResource.self)])
    }
}
