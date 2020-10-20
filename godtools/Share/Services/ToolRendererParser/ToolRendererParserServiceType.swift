//
//  ToolRendererParserServiceType.swift
//  godtools
//
//  Created by Levi Eggert on 10/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ToolRendererParserServiceType {
    
    associatedtype ToolRendererManifest: ToolRendererManifestType
    
    var manifest: ToolRendererManifest { get }
}
