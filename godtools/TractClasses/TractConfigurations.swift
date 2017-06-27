//
//  TractConfigurations.swift
//  godtools
//
//  Created by Devserker on 5/15/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractConfigurations: NSObject {
    
    var defaultTextAlignment: NSTextAlignment = .left
    var pagination: TractPagination?
    
    static func isFirstTimeAccess() -> Bool {
        return !UserDefaults.standard.bool(forKey: GTConstants.kAlreadyAccessTract)
    }
    
    static func didAccessToTract() {
        UserDefaults.standard.set(false, forKey: GTConstants.kAlreadyAccessTract)
    }
    
}
