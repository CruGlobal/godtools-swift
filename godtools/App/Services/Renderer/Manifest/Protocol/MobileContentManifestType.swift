//
//  MobileContentManifestType.swift
//  godtools
//
//  Created by Levi Eggert on 10/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol MobileContentManifestType {
    
    typealias TipId = String
    typealias ResourceFilename = String
        
    var attributes: MobileContentManifestAttributesType { get }
    var title: String? { get }
    var pages: [MobileContentManifestPageType] { get }
    var tips: [TipId: MobileContentManifestTipType] { get }
    var resources: [ResourceFilename: MobileContentManifestResourceType] { get }
}
