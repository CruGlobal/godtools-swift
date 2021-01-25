//
//  MobileContentRenderableContainerView.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol MobileContentRenderableContainerView: MobileContentRenderableView {
    
    func addRenderableView(renderableView: MobileContentRenderableView)
}
