//
//  LearnToShareToolViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LearnToShareToolViewModel: NSObject, LearnToShareToolViewModelType {
    
    private let learnToShareToolItemsProvider: LearnToShareToolItemsProviderType
    
    private weak var flowDelegate: FlowDelegate?
    
    let continueTitle: String
    let startTrainingTitle: String
    let numberOfLearnToShareToolItems: ObservableValue<Int> = ObservableValue(value: 0)
    
    required init(flowDelegate: FlowDelegate, learnToShareToolItemsProvider: LearnToShareToolItemsProviderType, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.learnToShareToolItemsProvider = learnToShareToolItemsProvider
        self.continueTitle = localizationServices.stringForMainBundle(key: "tutorial.continueButton.title.continue")
        self.startTrainingTitle = localizationServices.stringForMainBundle(key: "start_training")
        
        super.init()
        
        setupBinding()
    }
    
    deinit {
        learnToShareToolItemsProvider.learnToShareToolItems.removeObserver(self)
    }
    
    private func setupBinding() {
        
        learnToShareToolItemsProvider.learnToShareToolItems.addObserver(self) { [weak self] (items: [LearnToShareToolItem]) in
            self?.numberOfLearnToShareToolItems.accept(value: items.count)
        }
    }
    
    func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromLearnToShareTool)
    }
    
    func pageDidChange(page: Int) {
        
    }
    
    func pageDidAppear(page: Int) {
        
    }
    
    func continueTapped() {
        print("continue tapped")
    }
    
    func willDisplayLearnToShareToolPage(index: Int) -> LearnToShareToolCellViewModelType {
        
        return LearnToShareToolCellViewModel(
            learnToShareToolItem: learnToShareToolItemsProvider.learnToShareToolItems.value[index]
        )
    }
}
