//
//  MobileContentRendererViewFactoryType.swift
//  godtools
//
//  Created by Levi Eggert on 1/25/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol MobileContentRendererViewFactoryType {
    
    func viewForRenderableNode(renderableNode: MobileContentRenderableNode) -> MobileContentRenderableView?
}
