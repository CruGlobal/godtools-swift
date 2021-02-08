//
//  DeepLinkParsersContainer.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class DeepLinkParsersContainer {
    
    let parsers: [DeepLinkParserType]
    
    required init() {
        
        parsers = [
            ToolDeepLinkParser()
        ]
    }
}
