//
//  ToolPageContentStackContainerViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 11/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolPageContentStackContainerViewModelType {
    
    var contentStackRenderer: ToolPageContentStackRenderer { get }
    
    init(node: MobileContentXmlNode, diContainer: ToolPageDiContainer, toolPageColors: ToolPageColorsViewModel, defaultTextNodeTextColor: UIColor?, defaultTextNodeTextAlignment: NSTextAlignment?, defaultButtonBorderColor: UIColor?)
}
