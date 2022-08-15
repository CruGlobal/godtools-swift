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
    
    init() {
        
    }
    
    func getResourcesPlusLatestTranslationsAndAttachments() -> Result<ResourcesPlusLatestTranslationsAndAttachmentsModel, Error> {
        
        let jsonServices: JsonServices = JsonServices()
        let result: Result<Data?, Error> = jsonServices.getJsonData(fileName: "resources")
        
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
