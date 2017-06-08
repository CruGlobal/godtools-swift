//
//  GTGlobalBindings.swift
//  godtools
//
//  Created by Pablo Marti on 6/8/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class GTGlobalBindings: NSObject {
    
    enum Bindings:String {
        case followUp = "followup:send"
    }
    
    static func listen(listener: String, element: BaseTractElement) {
        switch listener {
        case Bindings.followUp.rawValue:
            let manager = FollowUpsManager()
            _ = manager.createSubscriber(params: element.getFormData()!)
            break
        default: break
        }
    }

}
