//
//  MobileContentHeadingViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/25/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentHeadingViewModel: MobileContentHeadingViewModelType {
    
    private let heading: Text
    private let rendererPageModel: MobileContentRendererPageModel
    
    required init(heading: Text, rendererPageModel: MobileContentRendererPageModel) {
        
        self.heading = heading
        self.rendererPageModel = rendererPageModel
    }
    
    var fontSize: CGFloat {
        return 30
    }
    
    var fontWeight: UIFont.Weight {
        return .regular
    }
    
    var textColor: UIColor {
        
        return heading.textColor
    }
}
