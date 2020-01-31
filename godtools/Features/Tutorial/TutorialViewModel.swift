//
//  TutorialViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TutorialViewModel: TutorialViewModelType {
    
    private var page: Int = 0
    
    private weak var flowDelegate: FlowDelegate?
    
    let hidesBackButton: ObservableValue<Bool> = ObservableValue(value: true)
    let tutorialItems: ObservableValue<[TutorialItem]> = ObservableValue(value: [])
    let currentTutorialItemIndex: ObservableValue<Int> = ObservableValue(value: 0)
    let continueButtonTitle: ObservableValue<String> = ObservableValue(value: "")
    
    required init(flowDelegate: FlowDelegate, tutorialItemsProvider: TutorialItemProviderType) {
        
        self.flowDelegate = flowDelegate
        
        tutorialItems.accept(value: tutorialItemsProvider.tutorialItems)
        
        setPage(page: 0)
    }
    
    private func setPage(page: Int) {
        
        guard page >= 0 && page < tutorialItems.value.count else {
            return
        }
        
        self.page = page
        
        hidesBackButton.accept(value: page == 0)
        
        currentTutorialItemIndex.accept(value: page)
        
        let isLastPage: Bool = page == tutorialItems.value.count - 1
        if isLastPage {
            continueButtonTitle.accept(value: NSLocalizedString("tutorial.continueButton.title.startUsingGodTools", comment: ""))
        }
        else {
            continueButtonTitle.accept(value: NSLocalizedString("tutorial.continueButton.title.continue", comment: ""))
        }
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
}
