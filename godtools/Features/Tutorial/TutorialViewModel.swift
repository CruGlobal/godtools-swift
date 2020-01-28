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
    
    let tutorialItems: ObservableValue<[TutorialItem]> = ObservableValue(value: [])
    let currentTutorialItemIndex: ObservableValue<Int> = ObservableValue(value: 0)
    let continueButtonTitle: ObservableValue<String> = ObservableValue(value: NSLocalizedString("tutorial.continueButton.title", comment: ""))
    
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
        
        currentTutorialItemIndex.accept(value: page)
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
            // TODO: Navigate?
            //flowDelegate?.navigate(step: )
        }
    }
}
