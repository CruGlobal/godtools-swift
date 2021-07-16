//
//  ContentVideoModelType.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ContentVideoModelType {
    
    var provider: String? { get }
    var videoId: String? { get }
    var providerType: MobileContentVideoNodeProvider { get }
}
