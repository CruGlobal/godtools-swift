//
//  TractPageCardAnalyticsScreenName.swift
//  godtools
//
//  Created by Levi Eggert on 11/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TractPageCardAnalyticsScreenName {
    
    private static let screenNames: [String] = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    
    let screenName: String
    
    init(cardPosition: Int) {
        
        if cardPosition >= 0 && cardPosition < TractPageCardAnalyticsScreenName.screenNames.count {
            screenName = TractPageCardAnalyticsScreenName.screenNames[cardPosition]
        }
        else if let lastName = TractPageCardAnalyticsScreenName.screenNames.last {
            screenName = lastName
        }
        else {
            screenName = ""
        }
    }
}
