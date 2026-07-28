//
//  RealmAppLanguageDirection.swift
//  godtools
//
//  Created by Levi Eggert on 5/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift

enum RealmAppLanguageDirection: String, PersistableEnum, Sendable {
    case leftToRight
    case rightToLeft
}
