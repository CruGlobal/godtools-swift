//
//  UIDevice.swift
//  godtools
//
//  Created by Pablo Marti on 11/6/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation

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
    
    func iPhoneX() -> Bool {
        #if DEBUG
            if UIDevice().userInterfaceIdiom == .phone {
                switch UIScreen.main.nativeBounds.height {
                case 1136:
                    //This is a ("iPhone 5 or 5S or 5C")
                    return false
                case 1334:
                    //This is a ("iPhone 6/6S/7/8")
                    return false
                case 1920, 2208:
                    //This is a ("iPhone 6+/6S+/7+/8+")
                    return false
                case 2436:
                    //This is a ("iPhone X")
                    return true
                default:
                    //This is a ("unknown")
                    return false
                }
            }
        #endif

        return modelName == "iPhone10,3" || modelName == "iPhone10,6"
    }
    
}
