//
//  ExitAppToUrl.swift
//  godtools
//
//  Created by Levi Eggert on 10/22/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI // TODO: Remove SwiftUI once udpating to FacebookSDK 17.3+ ~Levi

class ExitAppToUrl {
    
    static func open(url: URL) {
                
        // TODO: Remove Environment once udpating to FacebookSDK 17.3+ ~Levi
        // FBSDK uses method swizzling and is overriding UIApplication.shared.open(url) and within sdk version 16 is calling deprecated UIApplication.shared.openUrl. ~Levi
        @Environment(\.openURL) var environmentOpenUrl
        environmentOpenUrl(url)
        
        // TODO: Uncomment once udpating to FacebookSDK 17.3+ ~Levi
        //UIApplication.shared.open(url)
    }
}
