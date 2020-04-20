//
//  UIDevice.swift
//  godtools
//
//  Created by Pablo Marti on 11/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
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
