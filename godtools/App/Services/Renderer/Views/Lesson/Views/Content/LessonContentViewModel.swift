//
//  LessonContentViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 04/08/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class LessonContentViewModel: LessonContentViewModelType {
    
    private let contentModel: ContentModelType
    private let rendererPageModel: MobileContentRendererPageModel
    
    required init(contentModel: ContentModelType, rendererPageModel: MobileContentRendererPageModel) {
        
        self.contentModel = contentModel
        self.rendererPageModel = rendererPageModel
    }
    
    deinit {

    }
}
