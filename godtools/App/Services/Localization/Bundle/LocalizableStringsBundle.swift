//
//  LocalizableStringsBundle.swift
//  godtools
//
//  Created by Levi Eggert on 8/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class LocalizableStringsBundle {
    
    let bundle: Bundle
    
    init(bundle: Bundle) {
        
        self.bundle = bundle
    }
    
    func stringForKey(key: String) -> String? {
                
        let localizedString: String = bundle.localizedString(forKey: key, value: nil, table: nil)
        
        if localizedString.isEmpty {
            return nil
        }
        
        return localizedString
    }
}
