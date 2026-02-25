//
//  PreviewAssets.swift
//  godtools
//
//  Created by Levi Eggert on 2/24/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import UIKit

enum PreviewAssets: String {
    
    case tmtsTract = "tmts_tract"
    case tmtsManifest = "tmts_manifest"
    
    var data: Data? {
        return NSDataAsset(name: rawValue)?.data
    }
}
