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
    
    required init(flowDelegate: FlowDelegate, renderer: MobileContentRenderer, resource: ResourceModel, primaryLanguage: LanguageModel, page: Int?, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, mobileContentEventAnalytics: MobileContentEventAnalyticsTracking, trainingTipsEnabled: Bool) {
                
        self.flowDelegate = flowDelegate
        
        super.init(renderer: renderer, page: page, resourcesRepository: resourcesRepository, translationsRepository: translationsRepository, mobileContentEventAnalytics: mobileContentEventAnalytics, initialPageRenderingType: .visiblePages, trainingTipsEnabled: trainingTipsEnabled)
    }

    required init(renderer: MobileContentRenderer, page: Int?, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, mobileContentEventAnalytics: MobileContentEventAnalyticsTracking, initialPageRenderingType: MobileContentPagesInitialPageRenderingType, trainingTipsEnabled: Bool) {
        fatalError("init(renderer:page:resourcesRepository:translationsRepository:mobileContentEventAnalytics:initialPageRenderingType:trainingTipsEnabled:) has not been implemented")
    }
    
    override func handleDismissToolEvent() {
        super.handleDismissToolEvent()
        
        closeTapped()
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
                
        flowDelegate?.navigate(step: .closeTappedFromLesson(lesson: resource, highestPageNumberViewed: highestPageNumberViewed))
    }
}
