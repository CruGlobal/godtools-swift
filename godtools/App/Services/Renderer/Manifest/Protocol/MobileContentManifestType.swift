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
    
    associatedtype MobileContentManifestAttributes: MobileContentManifestAttributesType
    associatedtype MobileContentManifestPage: MobileContentManifestPageType
    associatedtype MobileContentManifestTip: MobileContentManifestTipType
    associatedtype MobileContentManifestResource: MobileContentManifestResourceType
    
    var attributes: MobileContentManifestAttributes { get }
    var title: String? { get }
    var pages: [MobileContentManifestPage] { get }
    var tips: [TipId: MobileContentManifestTip] { get }
    var resources: [ResourceFilename: MobileContentManifestResource] { get }
}
