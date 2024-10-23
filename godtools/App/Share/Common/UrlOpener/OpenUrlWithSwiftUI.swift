//
//  OpenUrlWithSwiftUI.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import SwiftUI

class OpenUrlWithSwiftUI: UrlOpenerInterface {
    
    init() {
        
    }
    
    func open(url: URL) {
        
        @Environment(\.openURL) var environmentOpenUrl
        environmentOpenUrl(url)
    }
}
