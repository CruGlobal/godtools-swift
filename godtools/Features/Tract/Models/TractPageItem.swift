//
//  TractPageItem.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TractPageItem {
    
    let tractPage: TractPage?
    let navigationEvent: TractRemoteShareNavigationEvent?
    
    required init(tractPage: TractPage?, navigationEvent: TractRemoteShareNavigationEvent?) {
        
        self.tractPage = tractPage
        self.navigationEvent = navigationEvent
    }
}
