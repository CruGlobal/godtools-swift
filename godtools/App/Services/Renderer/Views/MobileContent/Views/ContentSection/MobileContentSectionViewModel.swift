//
//  MobileContentSectionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentSectionViewModel: MobileContentSectionViewModelType {
    
    private let sectionNode: ContentSectionNode
    private let pageModel: MobileContentRendererPageModel
    
    required init(sectionNode: ContentSectionNode, pageModel: MobileContentRendererPageModel) {
        
        self.sectionNode = sectionNode
        self.pageModel = pageModel
    }
}
