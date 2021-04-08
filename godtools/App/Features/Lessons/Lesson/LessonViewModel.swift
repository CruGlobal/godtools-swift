//
//  LessonViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class LessonViewModel: MobileContentPagesViewModel, LessonViewModelType {
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, renderers: [MobileContentRenderer], resource: ResourceModel, primaryLanguage: LanguageModel, page: Int?) {
        
        self.flowDelegate = flowDelegate
        
        super.init(flowDelegate: flowDelegate, renderers: renderers, primaryLanguage: primaryLanguage, page: page)
    }
    
    required init(flowDelegate: FlowDelegate, renderers: [MobileContentRenderer], primaryLanguage: LanguageModel, page: Int?) {
        fatalError("init(flowDelegate:renderers:primaryLanguage:page:) has not been implemented")
    }
}
