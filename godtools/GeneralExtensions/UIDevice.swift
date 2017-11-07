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
        return modelName == "x86_64"
    }
    
}
