//
//  GetTranslatedPercentage.swift
//  godtools
//
//  Created by Rachael Skeath on 10/21/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class GetTranslatedPercentage {
    
    private static let sharedNumberFormatter: NumberFormatter = NumberFormatter()
    
    init() {
        
    }
    
    func getTranslatedPercentage(percentValue: Double, translateInLanguage: BCP47LanguageIdentifier) -> String {
        
        let formatter: NumberFormatter = GetTranslatedPercentage.sharedNumberFormatter
        
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        formatter.locale = Locale(identifier: translateInLanguage.localeId)
        
        return formatter.string(from: NSNumber(value: percentValue)) ?? "\(percentValue)%"
    }
}
