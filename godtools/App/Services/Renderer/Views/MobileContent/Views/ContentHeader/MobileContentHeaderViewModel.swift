//
//  MobileContentHeaderViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentHeaderViewModel: MobileContentHeaderViewModelType {
    
    private let header: Text
    private let rendererPageModel: MobileContentRendererPageModel
    
    required init(header: Text, rendererPageModel: MobileContentRendererPageModel) {
        
        self.header = header
        self.rendererPageModel = rendererPageModel
    }
    
    var fontSize: CGFloat {
        return 20
    }
    
    var fontWeight: UIFont.Weight {
        return .semibold
    }
    
    var textColor: UIColor {
        return .magenta
    }
}
