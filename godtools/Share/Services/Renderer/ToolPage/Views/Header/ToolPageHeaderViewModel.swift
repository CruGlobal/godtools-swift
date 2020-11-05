//
//  ToolPageHeaderViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageHeaderViewModel {
    
    private let fontService: FontService
    
    let headerNumber: String?
    let headerTitle: String?
    let hidesHeader: Bool
    let backgroundColor: UIColor
    let primaryTextColor: UIColor
    
    required init(pageNode: PageNode, backgroundColor: UIColor, primaryTextColor: UIColor, fontService: FontService) {
        
        self.fontService = fontService
        
        let pageHeaderNumber: String? = pageNode.headerNode?.number
        let pageHeaderTitle: String? = pageNode.headerNode?.title
        let hidesHeader: Bool = pageHeaderNumber == nil && pageHeaderTitle == nil
        
        headerNumber = pageHeaderNumber
        headerTitle = pageHeaderTitle
        self.hidesHeader = hidesHeader
        self.backgroundColor = backgroundColor
        self.primaryTextColor = primaryTextColor
    }
    
    var headerNumberFont: UIFont {
        return fontService.getFont(size: 54, weight: .regular)
    }
    
    var headerTitleFont: UIFont {
        return fontService.getFont(size: 19, weight: .regular)
    }
}
