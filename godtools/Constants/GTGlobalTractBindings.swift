//
//  GTGlobalTractBindings.swift
//  godtools
//
//  Created by Pablo Marti on 6/8/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class GTGlobalTractBindings: NSObject {
    
    enum Bindings:String {
        case followUp = "followup:send"
    }
    
    static func listen(listener: String, element: BaseTractElement) {
        switch listener {
        case Bindings.followUp.rawValue:
            let manager = FollowUpsManager()
            guard let form = BaseTractElement.getFormForElement(element) else {
                return
            }
            
            if(!form.validateForm()) {
                return
            }
            
            let params = form.getFormData()
            
            _ = manager.createSubscriber(params: params)
            break
        default: break
        }
    }

}
