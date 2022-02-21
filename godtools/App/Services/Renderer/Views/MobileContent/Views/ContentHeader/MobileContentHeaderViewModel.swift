//
//  MobileContentHeaderViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentHeaderViewModel: MobileContentHeaderViewModelType {
    
    private let headerModel: MultiplatformContentHeader
    private let rendererPageModel: MobileContentRendererPageModel
    
    required init(headerModel: MultiplatformContentHeader, rendererPageModel: MobileContentRendererPageModel) {
        
        self.headerModel = headerModel
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
