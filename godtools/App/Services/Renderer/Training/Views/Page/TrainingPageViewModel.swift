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
    
    required init(flowDelegate: FlowDelegate, pageNode: PageNode, pageModel: MobileContentRendererPageModel) {
        
        self.pageNode = pageNode
        self.pageModel = pageModel
        
        super.init(flowDelegate: flowDelegate, pageNode: pageNode, pageModel: pageModel, hidesBackgroundImage: true)
    }
    
    required init(flowDelegate: FlowDelegate, pageNode: PageNode, pageModel: MobileContentRendererPageModel, hidesBackgroundImage: Bool) {
        fatalError("init(flowDelegate:pageNode:pageModel:hidesBackgroundImage:) has not been implemented")
    }
}
