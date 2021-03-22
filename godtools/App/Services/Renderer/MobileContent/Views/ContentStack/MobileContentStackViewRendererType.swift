//
//  MobileContentStackViewRendererType.swift
//  godtools
//
//  Created by Levi Eggert on 11/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

// TODO: Remove this protocol. ~Levi
protocol MobileContentStackViewRendererType {
    
    func render(didRenderView: ((_ renderedView: MobileContentStackRenderedView) -> Void))
}
