//
//  AnalyticsRelay.swift
//  godtools
//
//  Created by Greg Weiss on 3/26/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import Foundation

class AnalyticsRelay {
    
    static let shared = AnalyticsRelay()
    
    var tractName: String = ""
    var tractCardName: String = ""
    var tractButtonName: String = ""
    var tractCardCurrentNames: [String] = []
    var tractCardNextNames: [String] = []
    var tractCardNumbers: [Int] = []
    var currentTractCardCount = 0
    var currentCard: String = ""
    var viewListener: String = ""
    var analyticsElement: BaseTractElement? = nil

}
