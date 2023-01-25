//
//  LanguagesJsonFileCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class LanguagesJsonFileCache {
    
    init() {
        
    }
    
    func getLanguages() -> Result<[LanguageModel], Error> {
        
        let jsonServices: JsonServices = JsonServices()
        let result: Result<Data?, Error> = jsonServices.getJsonData(fileName: "languages")
        
        switch result {
            
        case .success(let data):
            
            guard let data = data else {
                return .failure(NSError.errorWithDescription(description: "Failed to decode resources json data.  Null data."))
            }
            
            do {
                let responseData: JsonApiResponseData<[LanguageModel]> = try JSONDecoder().decode(JsonApiResponseData<[LanguageModel]>.self, from: data)
                return .success(responseData.data)
            }
            catch let error {
                return .failure(error)
            }
            
        case .failure(let error):
            return .failure(error)
        }
    }
}
