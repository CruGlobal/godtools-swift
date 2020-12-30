//
//  LearnToShareToolViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LearnToShareToolViewModel: NSObject, LearnToShareToolViewModelType {
    
    private let resource: ResourceModel
    private let learnToShareToolItemsProvider: LearnToShareToolItemsProviderType
    
    private var currentPage: Int = 0
    
    private weak var flowDelegate: FlowDelegate?
    
    let continueTitle: String
    let startTrainingTitle: String
    let numberOfLearnToShareToolItems: ObservableValue<Int> = ObservableValue(value: 0)
    
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, learnToShareToolItemsProvider: LearnToShareToolItemsProviderType, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
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
        flowDelegate?.navigate(step: .closeTappedFromLearnToShareTool(resource: resource))
    }
    
    func pageDidChange(page: Int) {
        currentPage = page
    }
    
    func pageDidAppear(page: Int) {
        currentPage = page
    }
    
    func continueTapped() {
        let isOnLastPage: Bool = currentPage >= numberOfLearnToShareToolItems.value - 1
        if isOnLastPage {
            flowDelegate?.navigate(step: .continueTappedFromLearnToShareTool(resource: resource))
        }
    }
    
    func willDisplayLearnToShareToolPage(index: Int) -> LearnToShareToolCellViewModelType {
        
        return LearnToShareToolCellViewModel(
            learnToShareToolItem: learnToShareToolItemsProvider.learnToShareToolItems.value[index]
        )
    }
}
