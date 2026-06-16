//
//  ToolNavigationFlow+ResumeLesson.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import UIKit
import GodToolsShared

extension ToolNavigationFlow {
    
    func getUserLessonProgress(lessonId: String) -> UserLessonProgressDataModel? {
        return appDiContainer.core.dataLayer.getUserLessonProgressRepository().getLessonProgress(lessonId: lessonId)
    }
    
    func getUserLessonProgressPage(lessonId: String) -> MobileContentRendererInitialPage? {
        
        guard let pageId = getUserLessonProgress(lessonId: lessonId)?.lastViewedPageId else {
            return nil
        }
        
        return .pageId(value: pageId)
    }
    
    func getShouldNavigateToResumeLesson(toolTranslations: ToolTranslationsDomainModel, toolOpenedFrom: ToolOpenedFrom) -> Bool {
        
        switch toolOpenedFrom {
        case .dashboardLessons, .dashboardFavoritesFeaturedLesson:
            break
            
        default:
            return false
        }
        
        let lessonProgressLastViewedPageId: String? = getUserLessonProgress(lessonId: toolTranslations.tool.id)?.lastViewedPageId
        
        let primaryLanguageManifest: Manifest? = toolTranslations.languageTranslationManifests.first?.manifest
        let visiblePages: [Page] = (primaryLanguageManifest?.pages ?? Array()).filter({!$0.isHidden})
        let hasLessonProgress: Bool = lessonProgressLastViewedPageId != nil
        let lessonProgressIsFirstPage: Bool = lessonProgressLastViewedPageId == visiblePages.first?.id
        let lessonProgressIsLastPage: Bool = lessonProgressLastViewedPageId == visiblePages.last?.id
        
        return hasLessonProgress && !lessonProgressIsFirstPage && !lessonProgressIsLastPage
    }
    
    func getResumeLessonModal(toolTranslations: ToolTranslationsDomainModel) -> UIViewController {
        
        let viewModel = ResumeLessonProgressModalViewModel(
            stepEmitter: stepEmitter,
            toolTranslations: toolTranslations,
            getResumeLessonProgressStringsUseCase: appDiContainer.feature.lessonProgress.domainLayer.getResumeLessonProgressStringsUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase()
        )
        
        let resumeLessonModal = ResumeLessonProgressModal(viewModel: viewModel)
        
        let hostingView = AppHostingController<ResumeLessonProgressModal>(
            rootView: resumeLessonModal,
            navigationBar: nil
        )
        
        hostingView.view.backgroundColor = .clear
        hostingView.modalPresentationStyle = .overFullScreen
        hostingView.modalTransitionStyle = .crossDissolve
        
        return hostingView
    }
}
