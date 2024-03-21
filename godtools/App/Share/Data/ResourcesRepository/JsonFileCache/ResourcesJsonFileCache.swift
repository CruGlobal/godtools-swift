//
//  ResourcesJsonFileCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class ResourcesJsonFileCache {
    
    private let jsonServices: JsonServices
    
    init(jsonServices: JsonServices) {
        
        self.jsonServices = jsonServices
    }
    
    func getResourcesPlusLatestTranslationsAndAttachments() -> Result<ResourcesPlusLatestTranslationsAndAttachmentsModel, Error> {
        
        return parseResourcesJsonFromBundle(fileName: "resources")
    }
    
    func parseResourcesJsonFromBundle(fileName: String) -> Result<ResourcesPlusLatestTranslationsAndAttachmentsModel, Error> {
        
        let result: Result<Data?, Error> = jsonServices.getJsonData(fileName: fileName)
        
        switch result {
            
        case .success(let data):
            
            guard let data = data else {
                return .failure(NSError.errorWithDescription(description: "Failed to decode resources json data.  Null data."))
            }
            
            do {
                let object: ResourcesPlusLatestTranslationsAndAttachmentsModel = try JSONDecoder().decode(ResourcesPlusLatestTranslationsAndAttachmentsModel.self, from: data)
                return .success(object)
            }
            catch let error {
                return .failure(error)
            }
            
        case .failure(let error):
            return .failure(error)
        }
    }
}
