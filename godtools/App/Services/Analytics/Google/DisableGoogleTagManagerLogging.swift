//
//  DisableGoogleTagManagerLogging.swift
//  godtools
//
//  Created by Levi Eggert on 8/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

// NOTE: This class has been added to disable GoogleTagManager logging to the Xcode console.
// Found solution here (https://stackoverflow.com/questions/45347538/how-to-disable-google-tag-manager-console-logging)
// This was added 8/25/2023, GoogleTagManager version 7.4.3.
// ~Levi

class DisableGoogleTagManagerLogging {
    
    static func disable() {
        
        let tagClass: AnyClass? = NSClassFromString("TAGLogger")

        let originalSelector = NSSelectorFromString("info:")
        let detourSelector = #selector(DisableGoogleTagManagerLogging.detour_info(message:))

        guard let originalMethod = class_getClassMethod(tagClass, originalSelector), let detourMethod = class_getClassMethod(DisableGoogleTagManagerLogging.self, detourSelector) else {
            return
        }

        class_addMethod(tagClass, detourSelector, method_getImplementation(detourMethod), method_getTypeEncoding(detourMethod))
       
        method_exchangeImplementations(originalMethod, detourMethod)
    }

    @objc static func detour_info(message: String) {
        
        return
    }
}
