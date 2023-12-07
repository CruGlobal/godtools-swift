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
    
    private let tool: ToolDomainModel
    private let getLearnToShareToolItemsUseCase: GetLearnToShareToolItemsUseCase
    private let localizationServices: LocalizationServices
    
    private var learnToShareToolItems: [LearnToShareToolItemDomainModel] = Array()
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published var hidesBackButton: Bool = true
    @Published var numberOfLearnToShareToolItems: Int = 0
    @Published var continueTitle: String = ""
    @Published var currentPage: Int = 0 {
        didSet {
            currentPageDidChange(page: currentPage)
        }
    }
    
    init(flowDelegate: FlowDelegate, tool: ToolDomainModel, getLearnToShareToolItemsUseCase: GetLearnToShareToolItemsUseCase, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.tool = tool
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
                
        self.continueTitle = localizationServices.stringForSystemElseEnglish(key: localizedKey)
        
        hidesBackButton = page == 0
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
        flowDelegate?.navigate(step: .closeTappedFromLearnToShareTool(tool: tool))
    }
    
    func continueTapped() {
        
        if isOnLastPage {
            flowDelegate?.navigate(step: .continueTappedFromLearnToShareTool(tool: tool))
        }
        else {
            currentPage = currentPage + 1
        }
    }
}
