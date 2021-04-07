//
//  TrainingPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class TrainingPageViewModel: TrainingPageViewModelType {
    
    private let pageNode: PageNode
    private let pageModel: MobileContentRendererPageModel
    
    required init(pageNode: PageNode, pageModel: MobileContentRendererPageModel) {
        
        self.pageNode = pageNode
        self.pageModel = pageModel
    }
}
