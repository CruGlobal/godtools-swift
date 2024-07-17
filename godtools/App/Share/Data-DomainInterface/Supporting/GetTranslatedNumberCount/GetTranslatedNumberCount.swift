//
//  GetTranslatedNumberCount.swift
//  godtools
//
//  Created by Levi Eggert on 4/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class GetTranslatedNumberCount {
    
    private static let sharedNumberFormatter: NumberFormatter = NumberFormatter()
    
    init() {
        
    }
    
    func getTranslatedCount(count: Int, translateInLanguage: BCP47LanguageIdentifier) -> String {
        
        let formatter: NumberFormatter = GetTranslatedNumberCount.sharedNumberFormatter
        
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: translateInLanguage)
        
        guard let formattedString = formatter.string(from: NSNumber(value: count)) else {
            return String(count)
        }
        
        return formattedString
    }
}
