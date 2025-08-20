//
//  SendFeedbackWebContent.swift
//  godtools
//
//  Created by Rachael Skeath on 4/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import LocalizationServices

struct SendFeedbackWebContent: WebContentType {
    
    let navTitle: String
    let url: URL? = URL(string: "https://godtoolsapp.com/send-feedback/")
    let analyticsScreenName: String = "Send Feedback"
    let analyticsSiteSection: String = "menu"
    
    init(localizationServices: LocalizationServicesInterface) {
        
        navTitle = localizationServices.stringForSystemElseEnglish(key: "menu.sendFeedback")
    }
}
