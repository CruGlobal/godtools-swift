//
//  SwiftDatabaseEnabled.swift
//  godtools
//
//  Created by Levi Eggert on 11/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

// TODO: GT-2753 Can be removed once RealmSwift is removed and supporting iOS 17.4 and up. ~Levi
enum SwiftDatabaseEnabled {
    
    private static let internalIsEnabled: Bool = false
    
    static var isEnabled: Bool {
        
        if #available(iOS 17.4, *), Self.internalIsEnabled {
            return true
        }
        
        return false
    }
}
