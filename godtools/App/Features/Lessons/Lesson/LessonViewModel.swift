//
//  LessonViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class LessonViewModel: MobileContentPagesViewModel, LessonViewModelType {
        
    let progress: ObservableValue<AnimatableValue<CGFloat>> = ObservableValue(value: AnimatableValue(value: 0, animated: false))
    
    required init(flowDelegate: FlowDelegate, renderers: [MobileContentRenderer], resource: ResourceModel, primaryLanguage: LanguageModel, page: Int?, mobileContentEventAnalytics: MobileContentEventAnalyticsTracking) {
                
        super.init(flowDelegate: flowDelegate, renderers: renderers, primaryLanguage: primaryLanguage, page: page, mobileContentEventAnalytics: mobileContentEventAnalytics, initialPageRenderingType: .visiblePages)
    }
    
    required init(flowDelegate: FlowDelegate, renderers: [MobileContentRenderer], primaryLanguage: LanguageModel, page: Int?, mobileContentEventAnalytics: MobileContentEventAnalyticsTracking, initialPageRenderingType: MobileContentPagesInitialPageRenderingType) {
        fatalError("init(flowDelegate:renderers:primaryLanguage:page:mobileContentEventAnalytics:initialPageRenderingType:) has not been implemented")
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
    
    func closeTapped() {
        
        guard let lesson = getCurrentRenderer()?.resource else {
            assertionFailure("Internal error, unable to fetch current renderer resource.  Resource should not be nil.")
            return
        }
        
        flowDelegate?.navigate(step: .closeTappedFromLesson(lesson: lesson, highestPageNumberViewed: highestPageNumberViewed))
    }
}
