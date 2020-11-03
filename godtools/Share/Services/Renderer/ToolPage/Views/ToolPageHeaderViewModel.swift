//
//  ToolPageHeaderViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageHeaderViewModel {
    
    let headerNumber: String?
    let headerTitle: String?
    let hidesHeader: Bool
    let backgroundColor: UIColor
    let primaryTextColor: UIColor
    
    required init(pageNode: PageNode, backgroundColor: UIColor, primaryTextColor: UIColor) {
        
        let pageHeaderNumber: String? = pageNode.headerNode?.number
        let pageHeaderTitle: String? = pageNode.headerNode?.title
        let hidesHeader: Bool = pageHeaderNumber == nil && pageHeaderTitle == nil
        
        headerNumber = pageHeaderNumber
        headerTitle = pageHeaderTitle
        self.hidesHeader = hidesHeader
        self.backgroundColor = backgroundColor
        self.primaryTextColor = primaryTextColor
    }
}
