//
//  UserDefaultsCacheInterface.swift
//  godtools
//
//  Created by Levi Eggert on 8/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

protocol UserDefaultsCacheInterface {
    
    func deleteValue(key: String)
    func getValue(key: String) -> Any?
    func cache(value: Any?, forKey: String)
    func commitChanges()
}
