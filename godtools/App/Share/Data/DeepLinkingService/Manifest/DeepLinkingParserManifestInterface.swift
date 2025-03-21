//
//  DeepLinkingParserManifestInterface.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol DeepLinkingParserManifestInterface {
    
    var parserClass: DeepLinkParserInterface.Type { get }
        
    func getParserIfValidIncomingDeepLink(incomingDeepLink: IncomingDeepLinkType) -> DeepLinkParserInterface?
}
