//
//  MobileContentHeaderViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentHeaderViewModel: MobileContentHeaderViewModelType {
    
    private let headerModel: ContentHeaderModelType
    private let pageModel: MobileContentRendererPageModel
    
    required init(headerModel: ContentHeaderModelType, pageModel: MobileContentRendererPageModel) {
        
        self.headerModel = headerModel
        self.pageModel = pageModel
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
