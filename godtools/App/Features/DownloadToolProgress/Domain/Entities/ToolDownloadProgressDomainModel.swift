//
//  ToolDownloadProgressDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct ToolDownloadProgressDomainModel {
    
    private static let numberFormatter: NumberFormatter = NumberFormatter()
    
    let value: String
    
    init(progress: Double, translateInLanguage: AppLanguageCodeDomainModel) {
        
        let numberFormatter = ToolDownloadProgressDomainModel.numberFormatter
        
        numberFormatter.numberStyle = .percent
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.locale = Locale(identifier: translateInLanguage)
                
        let formattedProgress: String? = numberFormatter.string(from: NSNumber(value: progress))
        
        value = formattedProgress ?? ""
    }
}
