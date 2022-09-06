//
//  GoogleAdwordsAnalytics.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class GoogleAdwordsAnalytics {
 
    private let config: AppConfig
    
    required init(config: AppConfig) {
        
        self.config = config
    }
    
    func recordAdwordsConversion() {
        
        ACTConversionReporter.report(
            withConversionID: config.googleAdwordsConversionId,
            label: config.googleAdwordsLabel,
            value: "1.00",
            isRepeatable: false
        )
    }
}
