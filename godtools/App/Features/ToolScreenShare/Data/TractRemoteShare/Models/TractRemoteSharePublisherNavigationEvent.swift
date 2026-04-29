//
//  TractRemoteSharePublisherNavigationEvent.swift
//  godtools
//
//  Created by Levi Eggert on 11/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct TractRemoteSharePublisherNavigationEvent: Sendable {
    
    let card: Int?
    let locale: String?
    let page: Int?
    let parallelLocale: String?
    let primaryLocale: String?
    let tool: String?
}
