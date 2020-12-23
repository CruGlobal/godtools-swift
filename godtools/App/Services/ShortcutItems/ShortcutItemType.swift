//
//  ShortcutItemType.swift
//  godtools
//
//  Created by Levi Eggert on 6/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

enum ShortcutItemType: String {
    
    case tool = "tool"
    
    static func shortcutItemType(shortcutItem: UIApplicationShortcutItem) -> ShortcutItemType? {
        return ShortcutItemType(rawValue: shortcutItem.type)
    }
}
