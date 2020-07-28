//
//  DeepLinkingType.swift
//  godtools
//
//  Created by Levi Eggert on 6/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum DeepLinkingType {
    
    case none
    case tool(resource: ResourceModel, primaryLanguage: LanguageModel, parallelLanguage: LanguageModel?, liveShareStream: String?, page: Int?)
}
