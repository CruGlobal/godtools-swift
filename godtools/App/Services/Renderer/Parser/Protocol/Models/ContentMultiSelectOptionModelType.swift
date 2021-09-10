//
//  ContentMultiSelectOptionModelType.swift
//  godtools
//
//  Created by Levi Eggert on 9/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol ContentMultiSelectOptionModelType: MobileContentRenderableModel {
    
    var backgroundColor: UIColor { get }
    var selectedColor: UIColor { get }
    
    func toggleSelected(rendererState: MobileContentMultiplatformState)
    func watchIsSelected(rendererState: MobileContentMultiplatformState, completion: @escaping ((_ isSelected: Bool) -> Void)) -> MultiplatformFlowWatcher
}

extension ContentMultiSelectOptionModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
