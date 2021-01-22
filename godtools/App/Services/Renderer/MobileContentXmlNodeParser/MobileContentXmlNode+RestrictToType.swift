//
//  MobileContentXmlNode+RestrictToType.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

extension MobileContentXmlNode {
    
    var restrictToType: MobileContentRestrictToType {
        
        guard let restrictToValue = restrictTo else {
            return .noRestriction
        }
        
        guard let restrictToType = MobileContentRestrictToType(rawValue: restrictToValue) else {
            return .noRestriction
        }
        
        return restrictToType
    }
}
