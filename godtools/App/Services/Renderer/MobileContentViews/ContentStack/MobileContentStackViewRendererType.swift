//
//  MobileContentStackViewRendererType.swift
//  godtools
//
//  Created by Levi Eggert on 11/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol MobileContentStackViewRendererType {
    
    func render(didRenderView: ((_ renderedView: MobileContentStackRenderedView) -> Void))
}
