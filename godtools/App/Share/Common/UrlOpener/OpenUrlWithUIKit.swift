//
//  OpenUrlWithUIKit.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import UIKit

final class OpenUrlWithUIKit: UrlOpenerInterface {
    
    init() {
        
    }
    
    func open(url: URL) {
        
        UIApplication.shared.open(url)
    }
}

