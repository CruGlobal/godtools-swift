//
//  LessonViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import Combine

class LessonViewModel: MobileContentRendererViewModel {
    
    private static var storeLessonProgressCancellable: AnyCancellable?
    
    private let storeLessonProgressUseCase: StoreUserLessonProgressUseCase
    
    let progress: ObservableValue<AnimatableValue<CGFloat>> = ObservableValue(value: AnimatableValue(value: 0, animated: false))
    
    private weak var flowDelegate: FlowDelegate?
    
    init(flowDelegate: FlowDelegate, renderer: MobileContentRenderer, resource: ResourceDataModel, primaryLanguage: LanguageDataModel, initialPage: MobileContentRendererInitialPage?, initialPageConfig: MobileContentRendererInitialPageConfig?, initialPageSubIndex: Int?, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository, mobileContentEventAnalytics: MobileContentRendererEventAnalyticsTracking, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getTranslatedLanguageName: GetTranslatedLanguageName, storeLessonProgressUseCase: StoreUserLessonProgressUseCase, trainingTipsEnabled: Bool, incrementUserCounterUseCase: IncrementUserCounterUseCase) {
                
        self.flowDelegate = flowDelegate
        self.storeLessonProgressUseCase = storeLessonProgressUseCase
                
        super.init(renderer: renderer, initialPage: initialPage, initialPageConfig: initialPageConfig, initialPageSubIndex: initialPageSubIndex, resourcesRepository: resourcesRepository, translationsRepository: translationsRepository, mobileContentEventAnalytics: mobileContentEventAnalytics, getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, getTranslatedLanguageName: getTranslatedLanguageName, trainingTipsEnabled: trainingTipsEnabled, incrementUserCounterUseCase: incrementUserCounterUseCase, selectedLanguageIndex: nil)
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
        let pagesCount: CGFloat = CGFloat(super.getNumberOfPages())
        let newProgress: CGFloat
        
        if pagesCount > 0 {
            newProgress = currentPage / pagesCount
        }
        else {
            newProgress = 0
        }
        
        progress.accept(value: AnimatableValue(value: newProgress, animated: true))
    }
    
    private func updateUserLessonCompletionProgress(page: Int) {
        
        guard let currentPage = getPage(index: page) else {
            return
        }
        
        let resourceId: String = currentPageRenderer.value.resource.id
        
        Self.storeLessonProgressCancellable?.cancel()
        
        Self.storeLessonProgressCancellable = storeLessonProgressUseCase.storeLessonProgress(
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

// MARK: - Inputs

extension LessonViewModel {
    
    func lessonMostVisiblePageDidChange(page: Int) {
        updateProgress(page: page)
        updateUserLessonCompletionProgress(page: page)
    }
    
    func shareTapped() {
        
        flowDelegate?.navigate(step: .shareLessonTappedFromLesson(pageNumber: currentPageNumber))
    }
    
    func closeTapped() {
                
        flowDelegate?.navigate(step: .closeTappedFromLesson(lessonId: resource.id, highestPageNumberViewed: highestPageNumberViewed))
    }
}
