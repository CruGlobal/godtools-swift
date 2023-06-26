//
//  LearnToShareToolViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

class LearnToShareToolViewModel {
    
    private let resource: ResourceModel
    private let getLearnToShareToolItemsUseCase: GetLearnToShareToolItemsUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var learnToShareToolItems: [LearnToShareToolItemDomainModel] = Array()
    private var currentPage: Int = 0
    
    private weak var flowDelegate: FlowDelegate?
    
    let continueTitle: String
    let startTrainingTitle: String
    let numberOfLearnToShareToolItems: ObservableValue<Int> = ObservableValue(value: 0)
    
    init(flowDelegate: FlowDelegate, resource: ResourceModel, getLearnToShareToolItemsUseCase: GetLearnToShareToolItemsUseCase, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.getLearnToShareToolItemsUseCase = getLearnToShareToolItemsUseCase
        self.continueTitle = localizationServices.stringForMainBundle(key: "tutorial.continueButton.title.continue")
        self.startTrainingTitle = localizationServices.stringForMainBundle(key: "start_training")
            
        getLearnToShareToolItemsUseCase.getItemsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (items: [LearnToShareToolItemDomainModel]) in
                
                self?.learnToShareToolItems = items
                self?.numberOfLearnToShareToolItems.accept(value: items.count)
            }
            .store(in: &cancellables)
    }
    
    func pageDidChange(page: Int) {
        currentPage = page
    }
    
    func pageDidAppear(page: Int) {
        currentPage = page
    }
    
    func getLearnToShareToolItemViewModel(index: Int) -> LearnToShareToolItemViewModel {
        
        return LearnToShareToolItemViewModel(
            learnToShareToolItem: learnToShareToolItems[index]
        )
    }
}

// MARK: - Inputs

extension LearnToShareToolViewModel {
    
    func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromLearnToShareTool(resource: resource))
    }
    
    func continueTapped() {
        let isOnLastPage: Bool = currentPage >= numberOfLearnToShareToolItems.value - 1
        if isOnLastPage {
            flowDelegate?.navigate(step: .continueTappedFromLearnToShareTool(resource: resource))
        }
    }
}
