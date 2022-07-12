//
//  WebContentType.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol WebContentType {
    
    var navTitle: String { get }
    var url: URL? { get }
    var analyticsScreenName: String { get }
    var analyticsSiteSection: String { get }
}
