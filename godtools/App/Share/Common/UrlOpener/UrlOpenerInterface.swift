//
//  UrlOpenerInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

protocol UrlOpenerInterface: Sendable {
    
    @MainActor func open(url: URL)
}
