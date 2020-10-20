//
//  ToolRendererManifestType.swift
//  godtools
//
//  Created by Levi Eggert on 10/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ToolRendererManifestType {
    
    associatedtype ToolRendererManifestPage: ToolRendererManifestPageType
    associatedtype ToolRendererManifestTip: ToolRendererManifestTipType
    associatedtype ToolRendererManifestResource: ToolRendererManifestResourceType
    
    var title: String? { get }
    var pages: [ToolRendererManifestPage] { get }
    var tips: [ToolRendererManifestTip] { get }
    var resources: [ToolRendererManifestResource] { get }
}
