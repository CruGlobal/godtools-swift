//
//  TractCallToActionActions.swift
//  godtools
//
//  Created by Devserker on 5/29/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

extension TractCallToAction {
    
    func moveToNextView() {
        print("Move to next view")
        NotificationCenter.default.post(name: .moveToNextPageNotification, object: nil)
    }
    
}
