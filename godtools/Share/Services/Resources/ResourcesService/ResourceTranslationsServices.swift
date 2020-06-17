//
//  ResourceTranslationsServices.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourceTranslationsServices {
    
    typealias ResourceId = String
    
    private let translationsApi: TranslationsApiType
    
    private var services: [ResourceId: ResourceTranslationsService] = Dictionary()
    
    required init(translationsApi: TranslationsApiType) {
        
        self.translationsApi = translationsApi
    }
    
    func getResourceTranslationsService(resourceId: String) -> ResourceTranslationsService {
        
        if let service = services[resourceId] {
            return service
        }
        
        let newService =  ResourceTranslationsService(
            translationsApi: translationsApi
        )
        
        services[resourceId] = newService
        
        return newService
    }
}
