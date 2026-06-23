//
//  LessonViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import Combine

@MainActor
final class LessonViewModel: MobileContentRendererViewModel {
        
    private let stepEmitter: FlowStepEmitter
    private let storeLessonProgressUseCase: StoreUserLessonProgressUseCase
    
    private var storeLessonProgressTask: Task<Void, Error>?
    
    let progress: ObservableValue<AnimatableValue<CGFloat>> = ObservableValue(value: AnimatableValue(value: 0, animated: false))
        
    init(
        stepEmitter: FlowStepEmitter,
        renderer: MobileContentRenderer,
        resource: ResourceDataModel,
        primaryLanguage: LanguageDataModel,
        initialPage: MobileContentRendererInitialPage?,
        initialPageConfig: MobileContentRendererInitialPageConfig?,
        initialPageSubIndex: Int?,
        resourcesRepository: ResourcesRepository,
        translationsRepository: TranslationsRepository,
        mobileContentEventAnalytics: MobileContentRendererEventAnalyticsTracking,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getTranslatedLanguageName: GetTranslatedLanguageName,
        storeLessonProgressUseCase: StoreUserLessonProgressUseCase,
        trainingTipsEnabled: Bool,
        incrementUserCounterUseCase: IncrementUserCounterUseCase
    ) {
                
        self.stepEmitter = stepEmitter
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
        
        storeLessonProgressTask?.cancel()
        
        storeLessonProgressTask = Task {
            
            _ = try await storeLessonProgressUseCase
                .execute(
                    lessonId: resourceId,
                    viewedPageId: currentPage.id,
                    viewedPageNumber: page,
                    totalPageCount: getPages().count
                )
        }
    }
}

// MARK: - Inputs

extension LessonViewModel {
    
    func lessonMostVisiblePageDidChange(page: Int) {
        updateProgress(page: page)
        updateUserLessonCompletionProgress(page: page)
    }
    
    func shareTapped() {
        guard let languageId = renderer.value.pageRenderers.first?.language.id else { return }
        let pageNumber = getCurrentPageNumberWithHiddenPagesIncluded() ?? currentPageNumber
        
        stepEmitter.emit(step: AppFlowStep.shareLessonTappedFromLesson(pageNumber: pageNumber, languageId: languageId))
    }
    
    func closeTapped() {
                
        stepEmitter.emit(step: AppFlowStep.closeTappedFromLesson(lessonId: resource.id, highestPageNumberViewed: highestPageNumberViewed))
    }
}
