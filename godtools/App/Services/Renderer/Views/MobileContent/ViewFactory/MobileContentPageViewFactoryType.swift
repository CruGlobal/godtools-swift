//
//  MobileContentPageViewFactoryType.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

protocol MobileContentPageViewFactoryType {
    
    var flowDelegate: FlowDelegate? { get }
    
    func viewForRenderableModel(renderableModel: Any, rendererPageModel: MobileContentRendererPageModel) -> MobileContentView?
}
