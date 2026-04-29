//
//  ResourcesJsonFileCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

final class ResourcesJsonFileCache {
    
    private let jsonServices: JsonServices
    
    init(jsonServices: JsonServices) {
        
        self.jsonServices = jsonServices
    }
    
    func getResourcesPlusLatestTranslationsAndAttachments() throws -> ResourcesPlusLatestTranslationsAndAttachmentsCodable {
        
        return try parseResourcesJsonFromBundle(fileName: "resources")
    }
    
    func parseResourcesJsonFromBundle(fileName: String) throws -> ResourcesPlusLatestTranslationsAndAttachmentsCodable {
        
        let data: Data = try jsonServices.getJsonData(fileName: fileName)
        
        let object: ResourcesPlusLatestTranslationsAndAttachmentsCodable = try JSONDecoder().decode(ResourcesPlusLatestTranslationsAndAttachmentsCodable.self, from: data)
        
        return object
    }
}
