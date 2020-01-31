//
//  UserDefaults+Extension.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static func saveData(data: Any?, key: String) {
        let standardUserDefaults: UserDefaults = UserDefaults.standard
        standardUserDefaults.set(data, forKey: key)
        standardUserDefaults.synchronize()
    }
    
    static func getData(key:String) -> Any? {
        let standardUserDefaults: UserDefaults = UserDefaults.standard
        return standardUserDefaults.object(forKey: key)
    }
}
