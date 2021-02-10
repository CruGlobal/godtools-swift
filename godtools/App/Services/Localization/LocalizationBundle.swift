//
//  LocalizationBundle.swift
//  godtools
//
//  Created by Levi Eggert on 2/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class LocalizationBundle {
    
    let bundle: Bundle
    
    required init(bundle: Bundle) {
        
        self.bundle = bundle
    }
    
    func stringForKey(key: String) -> String? {
                
        let localizedString: String = bundle.localizedString(forKey: key, value: nil, table: nil)
        
        if localizedString.isEmpty || localizedString.lowercased() == key.lowercased() {
            return nil
        }
        
        return localizedString
    }
    
    func stringForKeyElseKey(key: String) -> String {
        
        return stringForKey(key: key) ?? key
    }
}
