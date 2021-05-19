//
//  TrainingPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class TrainingPageViewModel: MobileContentPageViewModel, TrainingPageViewModelType {
    
    private let pageNode: PageNode
    private let pageModel: MobileContentRendererPageModel
    
    required init(pageNode: PageNode, pageModel: MobileContentRendererPageModel) {
        
        self.pageNode = pageNode
        self.pageModel = pageModel
        
        super.init(pageNode: pageNode, pageModel: pageModel, hidesBackgroundImage: true)
    }
    
    required init(pageNode: PageNode, pageModel: MobileContentRendererPageModel, hidesBackgroundImage: Bool) {
        fatalError("init(pageNode:pageModel:hidesBackgroundImage:) has not been implemented")
    }
}
