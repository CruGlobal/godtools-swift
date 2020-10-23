//
//  RendererManifestType.swift
//  godtools
//
//  Created by Levi Eggert on 10/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol RendererManifestType {
    
    typealias TipId = String
    typealias ResourceFilename = String
    
    associatedtype RendererManifestAttributes: RendererManifestAttributesType
    associatedtype RendererManifestPage: RendererManifestPageType
    associatedtype RendererManifestTip: RendererManifestTipType
    associatedtype RendererManifestResource: RendererManifestResourceType
    
    var attributes: RendererManifestAttributes { get }
    var title: String? { get }
    var pages: [RendererManifestPage] { get }
    var tips: [TipId: RendererManifestTip] { get }
    var resources: [ResourceFilename: RendererManifestResource] { get }
}
