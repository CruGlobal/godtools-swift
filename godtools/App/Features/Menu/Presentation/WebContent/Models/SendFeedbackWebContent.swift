//
//  SendFeedbackWebContent.swift
//  godtools
//
//  Created by Rachael Skeath on 4/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct SendFeedbackWebContent: WebContentType {
    
    let navTitle: String
    let url: URL? = URL(string: "https://form.asana.com/?k=zjG5sVjCeB0MCIjKea1IWg&d=657768513276")
    let analyticsScreenName: String = "Send Feedback"
    let analyticsSiteSection: String = "menu"
    
    init(localizationServices: LocalizationServices) {
        
        navTitle = localizationServices.stringForMainBundle(key: "menu.sendFeedback")
    }
}
