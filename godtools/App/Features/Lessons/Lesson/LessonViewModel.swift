//
//  LessonViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class LessonViewModel: MobileContentPagesViewModel, LessonViewModelType {
    
    private weak var flowDelegate: FlowDelegate?
    
    let progress: ObservableValue<AnimatableValue<CGFloat>> = ObservableValue(value: AnimatableValue(value: 0, animated: false))
    
    required init(flowDelegate: FlowDelegate, renderers: [MobileContentRendererType], resource: ResourceModel, primaryLanguage: LanguageModel, page: Int?) {
        
        self.flowDelegate = flowDelegate
        
        super.init(flowDelegate: flowDelegate, renderers: renderers, primaryLanguage: primaryLanguage, page: page)
    }
    
    required init(flowDelegate: FlowDelegate, renderers: [MobileContentRendererType], primaryLanguage: LanguageModel, page: Int?) {
        fatalError("init(flowDelegate:renderers:primaryLanguage:page:) has not been implemented")
    }
    
    private func updateProgress(page: Int) {
        
        let currentPage: CGFloat = CGFloat(page + 1)
        let pagesCount: CGFloat = CGFloat(numberOfPages.value)
        let newProgress: CGFloat
        
        if pagesCount > 0 {
            newProgress = currentPage / pagesCount
        }
        else {
            newProgress = 0
        }
        
        progress.accept(value: AnimatableValue(value: newProgress, animated: true))
    }
    
    func lessonMostVisiblePageDidChange(page: Int) {
        updateProgress(page: page)
    }
    
    func closeTapped(page: Int) {
        
        guard let lesson = getCurrentRenderer()?.resource else {
            assertionFailure("Internal error, unable to fetch current renderer resource.  Resource should not be nil.")
            return
        }
        
        flowDelegate?.navigate(step: .closeTappedFromLesson(lesson: lesson, page: page))
    }
}
