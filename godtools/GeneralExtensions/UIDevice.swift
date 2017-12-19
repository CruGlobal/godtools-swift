//
//  UIDevice.swift
//  godtools
//
//  Created by Pablo Marti on 11/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

extension UIDevice {
    
    func iPhoneX() -> Bool {
        if UIDevice().userInterfaceIdiom == .phone {
            return 2436 == UIScreen.main.nativeBounds.height
        }
        return false
    }
}
