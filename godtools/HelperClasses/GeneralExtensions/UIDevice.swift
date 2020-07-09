//
//  UIDevice.swift
//  godtools
//
//  Created by Pablo Marti on 11/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

extension UIDevice {
    
    // TODO: I would like to remove this because this is not accurate and should not be used. ~Levi
    func iPhoneWithNotch() -> Bool {
        
        if #available(iOS 11.0, *) {
            if UIApplication.shared.statusBarOrientation.isLandscape {
                return false
            }
            return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0 > 0
        }
        
        return false
    }

    
}
