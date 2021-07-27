//
//  MobileContentTextScale.swift
//  godtools
//
//  Created by Levi Eggert on 5/4/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

struct MobileContentTextScale {
        
    let doubleValue: Double
    
    init(textScaleString: String?) {
                
        if let stringValue = textScaleString, let doubleValue = Double(stringValue) {
            self.doubleValue = doubleValue
        }
        else {
            self.doubleValue = 1
        }
    }
    
    init(doubleValue: Double) {
        self.doubleValue = doubleValue
    }
}
