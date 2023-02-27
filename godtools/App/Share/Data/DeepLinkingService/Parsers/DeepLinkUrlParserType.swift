//
//  DeepLinkUrlParserType.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol DeepLinkUrlParserType: DeepLinkParserType {
    
    func parse(url: URL, pathComponents: [String], queryParameters: [String: Any]) -> ParsedDeepLinkType?
}
