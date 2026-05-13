//
//  LanguagesJsonFileCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class LanguagesJsonFileCache {
    
    private let jsonServices: JsonServices
    
    init(jsonServices: JsonServices) {
        
        self.jsonServices = jsonServices
    }
    
    func getLanguages() throws -> [LanguageCodable] {
        
        return try parseLanguagesJsonFromBundle(fileName: "languages")
    }
    
    private func parseLanguagesJsonFromBundle(fileName: String) throws -> [LanguageCodable] {
        
        let data: Data = try jsonServices.getJsonData(fileName: fileName)
        
        let responseData: JsonApiResponseDataArray<LanguageCodable> = try JSONDecoder().decode(JsonApiResponseDataArray<LanguageCodable>.self, from: data)
        
        return responseData.dataArray
    }
}
