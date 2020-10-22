//
//  ToolRendererManifestType.swift
//  godtools
//
//  Created by Levi Eggert on 10/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ToolRendererManifestType {
    
    typealias TipId = String
    typealias ResourceFilename = String
    
    associatedtype ToolRendererManifestAttributes: ToolRendererManifestAttributesType
    associatedtype ToolRendererManifestPage: ToolRendererManifestPageType
    associatedtype ToolRendererManifestTip: ToolRendererManifestTipType
    associatedtype ToolRendererManifestResource: ToolRendererManifestResourceType
    
    var attributes: ToolRendererManifestAttributes { get }
    var title: String? { get }
    var pages: [ToolRendererManifestPage] { get }
    var tips: [TipId: ToolRendererManifestTip] { get }
    var resources: [ResourceFilename: ToolRendererManifestResource] { get }
}
