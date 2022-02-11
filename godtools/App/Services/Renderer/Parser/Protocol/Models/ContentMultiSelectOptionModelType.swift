//
//  ContentMultiSelectOptionModelType.swift
//  godtools
//
//  Created by Levi Eggert on 9/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

protocol ContentMultiSelectOptionModelType: MobileContentRenderableModel {
    
    var backgroundColor: UIColor { get }
    var selectedColor: UIColor { get }
    
    func getTappedAnalyticsEvents() -> [AnalyticsEventModelType]
    func watchIsSelected(rendererState: State, completion: @escaping ((_ isSelected: Bool) -> Void)) -> FlowWatcher
    func toggleSelected(rendererState: State)
}

extension ContentMultiSelectOptionModelType {
    var modelContentIsRenderable: Bool {
        return true
    }
}
