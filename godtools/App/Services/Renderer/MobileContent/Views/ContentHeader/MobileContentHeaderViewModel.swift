//
//  MobileContentHeaderViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentHeaderViewModel: MobileContentHeaderViewModelType {
    
    private let headerNode: ContentHeaderNode
    private let pageModel: MobileContentRendererPageModel
    
    required init(headerNode: ContentHeaderNode, pageModel: MobileContentRendererPageModel) {
        
        self.headerNode = headerNode
        self.pageModel = pageModel
    }
    
    var fontSize: CGFloat {
        return 24
    }
    
    var fontWeight: UIFont.Weight {
        return .regular
    }
    
    var textColor: UIColor {
        return .magenta
    }
}
