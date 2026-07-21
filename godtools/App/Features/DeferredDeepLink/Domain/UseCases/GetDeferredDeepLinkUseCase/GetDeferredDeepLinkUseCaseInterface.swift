//
//  GetDeferredDeepLinkUseCaseInterface.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol GetDeferredDeepLinkUseCaseInterface {
    
    func execute() async -> ParsedDeepLinkType?
}
