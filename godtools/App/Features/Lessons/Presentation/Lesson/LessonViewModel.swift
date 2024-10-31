//
//  LessonViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import Combine

class LessonViewModel: MobileContentPagesViewModel {
    
    private weak var flowDelegate: FlowDelegate?
    private let storeLessonProgressUseCase: StoreUserLessonProgressUseCase
    private static var storeLessonProgressCancellable: AnyCancellable?
    
    let progress: ObservableValue<AnimatableValue<CGFloat>> = ObservableValue(value: AnimatableValue(value: 0, animated: false))
    
    init(flowDelegate: FlowDelegate, renderer: MobileContentRenderer, resource: ResourceModel, primaryLanguage: LanguageModel, initialPage: MobileContentPagesPage?, initialPageConfig: MobileContentPagesInitialPageConfig?, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, mobileContentEventAnalytics: MobileContentRendererEventAnalyticsTracking, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getTranslatedLanguageName: GetTranslatedLanguageName, storeLessonProgressUseCase: StoreUserLessonProgressUseCase, trainingTipsEnabled: Bool, incrementUserCounterUseCase: IncrementUserCounterUseCase) {
                
        self.flowDelegate = flowDelegate
        self.storeLessonProgressUseCase = storeLessonProgressUseCase
        
        let initialPageConfig = initialPageConfig ?? MobileContentPagesInitialPageConfig(shouldRestartAtBeginning: true, shouldNavigateToStartPageIfLastPage: true, shouldNavigateToPreviousVisiblePageIfHiddenPage: true)
        
        super.init(renderer: renderer, initialPage: initialPage, initialPageConfig: initialPageConfig, resourcesRepository: resourcesRepository, translationsRepository: translationsRepository, mobileContentEventAnalytics: mobileContentEventAnalytics, getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, getTranslatedLanguageName: getTranslatedLanguageName, initialPageRenderingType: .visiblePages, trainingTipsEnabled: trainingTipsEnabled, incrementUserCounterUseCase: incrementUserCounterUseCase, selectedLanguageIndex: nil)
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
        
        if let currentPage = getPage(index: page) {
            let resourceId = currentPageRenderer.value.resource.id

            if let storeLessonProgressCancellable = LessonViewModel.storeLessonProgressCancellable {
                storeLessonProgressCancellable.cancel()
                LessonViewModel.storeLessonProgressCancellable = nil
            }
            
            LessonViewModel.storeLessonProgressCancellable = storeLessonProgressUseCase.storeLessonProgress(
                lessonId: resourceId,
                lastViewedPageId: currentPage.id,
                lastViewedPageNumber: page,
                totalPageCount: getPages().count
            )
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { _ in
                
            })
        }
    }
}

// MARK: - Inputs

extension LessonViewModel {
    
    func lessonMostVisiblePageDidChange(page: Int) {
        updateProgress(page: page)
    }
    
    func closeTapped() {
                
        flowDelegate?.navigate(step: .closeTappedFromLesson(lessonId: resource.id, highestPageNumberViewed: highestPageNumberViewed))
    }
}
