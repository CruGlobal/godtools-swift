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
    var language: LanguageModel?
    var resource: ResourceModel?
    
    static func isFirstTimeAccess() -> Bool {
        return !UserDefaults.standard.bool(forKey: GTConstants.kAlreadyAccessTract)
    }
    
    static func didAccessToTract() {
        UserDefaults.standard.set(true, forKey: GTConstants.kAlreadyAccessTract)
    }
    
}
