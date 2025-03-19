//
//  DeepLinkingManifestInterface.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol DeepLinkingManifestInterface {
    
    var parserManifests: [DeepLinkingParserManifestInterface] { get }
}
