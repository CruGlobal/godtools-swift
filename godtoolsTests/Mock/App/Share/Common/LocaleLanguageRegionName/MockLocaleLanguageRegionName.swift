//
//  MockLocaleLanguageRegionName.swift
//  godtools
//
//  Created by Levi Eggert on 7/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class MockLocaleLanguageRegionName: LocaleLanguageRegionNameInterface {
    
    typealias RegionCode = String
    typealias TranslateInLocaleId = String
    typealias RegionName = String
    
    private let regionNames: [RegionCode: [TranslateInLocaleId: RegionName]]
    
    init(regionNames: [RegionCode: [TranslateInLocaleId: RegionName]]) {
        
        self.regionNames = regionNames
    }

    func getRegionName(forRegionCode: String, translatedInLanguageId: BCP47LanguageIdentifier?) -> String? {
        
        if let translatedInLanguageId = translatedInLanguageId {
            
            return regionNames[forRegionCode]?[translatedInLanguageId]
        }
        
        return regionNames[forRegionCode]?[forRegionCode]
    }
}
