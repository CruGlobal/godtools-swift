//
//  DeepLinkParserType.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol DeepLinkParserType {
            
    func parse(incomingDeepLink: IncomingDeepLinkType) -> ParsedDeepLinkType?
}
