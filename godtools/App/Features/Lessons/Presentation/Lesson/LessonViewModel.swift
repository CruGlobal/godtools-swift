//
//  LessonViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class LessonViewModel: MobileContentPagesViewModel {
    
    private weak var flowDelegate: FlowDelegate?
    
    let progress: ObservableValue<AnimatableValue<CGFloat>> = ObservableValue(value: AnimatableValue(value: 0, animated: false))
    
    init(flowDelegate: FlowDelegate, renderer: MobileContentRenderer, resource: ResourceModel, primaryLanguage: LanguageDomainModel, initialPage: MobileContentPagesPage?, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, mobileContentEventAnalytics: MobileContentRendererEventAnalyticsTracking, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, translatedLanguageNameRepository: TranslatedLanguageNameRepository, trainingTipsEnabled: Bool, incrementUserCounterUseCase: IncrementUserCounterUseCase) {
                
        self.flowDelegate = flowDelegate
        
        super.init(renderer: renderer,initialPage: initialPage, resourcesRepository: resourcesRepository, translationsRepository: translationsRepository, mobileContentEventAnalytics: mobileContentEventAnalytics, getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, translatedLanguageNameRepository: translatedLanguageNameRepository, initialPageRenderingType: .visiblePages, trainingTipsEnabled: trainingTipsEnabled, incrementUserCounterUseCase: incrementUserCounterUseCase, selectedLanguageIndex: nil)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }

    override func handleDismissToolEvent() {
        super.handleDismissToolEvent()
        
        closeTapped()
    }
    
    private func updateProgress(page: Int) {
        
        let currentPage: CGFloat = CGFloat(page + 1)
        let pagesCount: CGFloat = CGFloat(super.getNumberOfRenderedPages())
        let newProgress: CGFloat
        
        if pagesCount > 0 {
            newProgress = currentPage / pagesCount
        }
        else {
            newProgress = 0
        }
        
        progress.accept(value: AnimatableValue(value: newProgress, animated: true))
    }
}

// MARK: - Inputs

extension LessonViewModel {
    
    func lessonMostVisiblePageDidChange(page: Int) {
        updateProgress(page: page)
    }
    
    func closeTapped() {
                
        flowDelegate?.navigate(step: .closeTappedFromLesson(lesson: resource, highestPageNumberViewed: highestPageNumberViewed))
    }
}
