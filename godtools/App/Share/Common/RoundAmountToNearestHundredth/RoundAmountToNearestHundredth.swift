//
//  RoundAmountToNearestHundredth.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

public class RoundAmountToNearestHundredth {
    
    private let roundingBehavior: NSDecimalNumberHandler
        
    public init() {
                
        roundingBehavior = NSDecimalNumberHandler(
            roundingMode: .plain,
            scale: 2,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )
    }
    
    public func round(amount: Double) -> NSDecimalNumber {
        
        return NSDecimalNumber(value: amount).rounding(accordingToBehavior: roundingBehavior)
    }
    
    public func round(amount: String) -> NSDecimalNumber {
                
        return NSDecimalNumber(string: amount).rounding(accordingToBehavior: roundingBehavior)
    }
}
