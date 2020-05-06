//
//  TractCallToActionActions.swift
//  godtools
//
//  Created by Devserker on 5/29/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

@objc extension TractCallToAction {
    
    func moveToNextView() {
        NotificationCenter.default.post(name: .moveToNextPageNotification, object: nil)
    }
    
}
