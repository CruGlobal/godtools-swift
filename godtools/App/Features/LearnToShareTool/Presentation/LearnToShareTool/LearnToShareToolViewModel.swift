//
//  LearnToShareToolViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

class LearnToShareToolViewModel: ObservableObject {
    
    private let resource: ResourceModel
    private let getLearnToShareToolItemsUseCase: GetLearnToShareToolItemsUseCase
    private let localizationServices: LocalizationServices
    private let hidesBackButtonSubject: CurrentValueSubject<Bool, Never> = CurrentValueSubject(true)
    
    private var learnToShareToolItems: [LearnToShareToolItemDomainModel] = Array()
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var numberOfLearnToShareToolItems: Int = 0
    @Published var continueTitle: String = ""
    @Published var currentPage: Int = 0 {
        didSet {
            currentPageDidChange(page: currentPage)
        }
    }
    
    init(flowDelegate: FlowDelegate, resource: ResourceModel, getLearnToShareToolItemsUseCase: GetLearnToShareToolItemsUseCase, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.getLearnToShareToolItemsUseCase = getLearnToShareToolItemsUseCase
        self.localizationServices = localizationServices
                
        getLearnToShareToolItemsUseCase.getItemsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (items: [LearnToShareToolItemDomainModel]) in
                
                self?.learnToShareToolItems = items
                self?.numberOfLearnToShareToolItems = items.count
                self?.currentPageDidChange(page: self?.currentPage ?? 0)
            }
            .store(in: &cancellables)
    }
    
    private func currentPageDidChange(page: Int) {
        
        let localizedKey: String = isOnLastPage ? "start_training" : "tutorial.continueButton.title.continue"
                
        self.continueTitle = localizationServices.stringForMainBundle(key: localizedKey)
        
        hidesBackButtonSubject.send(page == 0)
    }
    
    private var isOnFirstPage: Bool {
        return currentPage == 0
    }
    
    private var isOnLastPage: Bool {
        
        guard numberOfLearnToShareToolItems > 0 else {
            return false
        }
        
        return currentPage >= numberOfLearnToShareToolItems - 1
    }
    
    var hidesBackButtonPublisher: AnyPublisher<Bool, Never> {
        return hidesBackButtonSubject
            .eraseToAnyPublisher()
    }

    func getLearnToShareToolItemViewModel(index: Int) -> LearnToShareToolItemViewModel {
        
        return LearnToShareToolItemViewModel(
            learnToShareToolItem: learnToShareToolItems[index]
        )
    }
}

// MARK: - Inputs

extension LearnToShareToolViewModel {
    
    @objc func backTapped() {
        
        guard !isOnFirstPage else {
            return
        }
        
        currentPage = currentPage - 1
    }
    
    @objc func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromLearnToShareTool(resource: resource))
    }
    
    func continueTapped() {
        
        if isOnLastPage {
            flowDelegate?.navigate(step: .continueTappedFromLearnToShareTool(resource: resource))
        }
        else {
            currentPage = currentPage + 1
        }
    }
}
