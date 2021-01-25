//
//  MobileContentRenderableView.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol MobileContentRenderableView {
    
    var view: UIView { get }
    
    func addRenderableView(renderableView: MobileContentRenderableView)
}
