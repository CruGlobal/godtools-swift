//
//  TutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TutorialViewModel: TutorialViewModelType {
    
    private let analytics: GodToolsAnaltyics
    
    private var trackedAnalyticsForYouTubeVideoIds: [String] = Array()
    private var page: Int = 0
    
    private weak var flowDelegate: FlowDelegate?
    
    let hidesBackButton: ObservableValue<Bool> = ObservableValue(value: true)
    let tutorialItems: ObservableValue<[TutorialItem]> = ObservableValue(value: [])
    let currentTutorialItemIndex: ObservableValue<Int> = ObservableValue(value: 0)
    let currentPage: ObservableValue<Int> = ObservableValue(value: 0)
    let continueButtonTitle: ObservableValue<String> = ObservableValue(value: "")
    
    required init(flowDelegate: FlowDelegate, analytics: GodToolsAnaltyics, tutorialItemsProvider: TutorialItemProviderType) {
        
        self.flowDelegate = flowDelegate
        self.analytics = analytics
        
        tutorialItems.accept(value: tutorialItemsProvider.tutorialItems)
        
        setPage(page: 0)
    }
    
    private func setPage(page: Int, shouldSetCurrentTutorialItemIndex: Bool = true) {
        
        guard page >= 0 && page < tutorialItems.value.count else {
            return
        }
        
        self.page = page
        
        if shouldSetCurrentTutorialItemIndex {
            currentTutorialItemIndex.accept(value: page)
        }
        
        currentPage.accept(value: page)
        
        hidesBackButton.accept(value: page == 0)
        
        let isLastPage: Bool = page == tutorialItems.value.count - 1
        if isLastPage {
            continueButtonTitle.accept(value: NSLocalizedString("tutorial.continueButton.title.startUsingGodTools", comment: ""))
        }
        else {
            continueButtonTitle.accept(value: NSLocalizedString("tutorial.continueButton.title.continue", comment: ""))
        }
        
        analytics.recordScreenView(
            screenName: "tutorial-\(page + 1)",
            siteSection: "tutorial",
            siteSubSection: ""
        )
    }
    
    func backTapped() {
        let prevPage: Int = page - 1
        setPage(page: prevPage)
    }
    
    func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromTutorial)
    }
    
    func pageTapped(page: Int) {
        setPage(page: page)
    }
    
    func didScrollToPage(page: Int) {
        setPage(page: page, shouldSetCurrentTutorialItemIndex: false)
    }
    
    func continueTapped() {
        
        let nextPage: Int = page + 1
        let reachedEnd: Bool = nextPage >= tutorialItems.value.count
        
        if !reachedEnd {
            setPage(page: nextPage)
        }
        else {
            flowDelegate?.navigate(step: .startUsingGodToolsTappedFromTutorial)
        }
    }
    
    func tutorialVideoPlayTapped() {
        
        let tutorialItem: TutorialItem = tutorialItems.value[page]
        
        guard let youTubeVideoId = tutorialItem.youTubeVideoId else {
            return
        }
        
        let youTubeVideoTracked: Bool = trackedAnalyticsForYouTubeVideoIds.contains(youTubeVideoId)
        
        if !youTubeVideoTracked {
            trackedAnalyticsForYouTubeVideoIds.append(youTubeVideoId)
            analytics.recordActionForADBMobile(screenName: "tutorial-1", actionName: "Tutorial Video", data: ["cru.tutorial_video": 1, "video_id": youTubeVideoId])
        }
    }
}
