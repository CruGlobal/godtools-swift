//
//  LanguagesJsonFileCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation

class LanguagesJsonFileCache {
    
    private let jsonServices: JsonServices
    
    init(jsonServices: JsonServices) {
        
        self.jsonServices = jsonServices
    }
    
    func getLanguages() -> Result<[LanguageCodable], Error> {
        
        return parseLanguagesJsonFromBundle(fileName: "languages")
    }
    
    func parseLanguagesJsonFromBundle(fileName: String) -> Result<[LanguageCodable], Error> {
        
        let result: Result<Data?, Error> = jsonServices.getJsonData(fileName: fileName)
        
        switch result {
            
        case .success(let data):
            
            guard let data = data else {
                return .failure(NSError.errorWithDescription(description: "Failed to decode resources json data.  Null data."))
            }
            
            do {
                let responseData: JsonApiResponseDataArray<LanguageCodable> = try JSONDecoder().decode(JsonApiResponseDataArray<LanguageCodable>.self, from: data)
                return .success(responseData.dataArray)
            }
            catch let error {
                return .failure(error)
            }
            
        case .failure(let error):
            return .failure(error)
        }
    }
}
