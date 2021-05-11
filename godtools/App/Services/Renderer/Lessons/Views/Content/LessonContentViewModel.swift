//
//  LessonContentViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 04/08/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class LessonContentViewModel: LessonContentViewModelType {
    
    private let contentNode: ContentNode
    private let pageModel: MobileContentRendererPageModel
    
    required init(contentNode: ContentNode, pageModel: MobileContentRendererPageModel) {
        
        self.contentNode = contentNode
        self.pageModel = pageModel
    }
    
    deinit {

    }
}
