//
//  LessonPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class LessonPageViewModel: LessonPageViewModelType {
    
    private let pageNode: PageNode
    private let pageModel: MobileContentRendererPageModel
    
    required init(pageNode: PageNode, pageModel: MobileContentRendererPageModel) {
            
        self.pageNode = pageNode
        self.pageModel = pageModel
    }
    
    var manifestDismissListeners: [String] {
        return pageModel.manifest.attributes.dismissListeners
    }
}
