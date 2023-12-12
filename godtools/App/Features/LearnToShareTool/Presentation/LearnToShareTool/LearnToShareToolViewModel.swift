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
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewLearnToShareToolUseCase: ViewLearnToShareToolUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private var viewLearnToShareToolDomainModel: ViewLearnToShareToolDomainModel?
    
    @Published var hidesBackButton: Bool = true
    @Published var learnToShareToolItems: [LearnToShareToolItemDomainModel] = Array()
    @Published var continueTitle: String = ""
    @Published var currentPage: Int = 0
    
    init(flowDelegate: FlowDelegate, tool: ToolDomainModel, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewLearnToShareToolUseCase: ViewLearnToShareToolUseCase) {
        
        self.flowDelegate = flowDelegate
        self.tool = tool
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewLearnToShareToolUseCase = viewLearnToShareToolUseCase
              
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        $appLanguage
            .eraseToAnyPublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewLearnToShareToolDomainModel, Never> in
                
                return self.viewLearnToShareToolUseCase
                    .viewPublisher(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: ViewLearnToShareToolDomainModel) in
                
                self?.viewLearnToShareToolDomainModel = domainModel
                self?.learnToShareToolItems = domainModel.tutorialItems
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $viewLearnToShareToolDomainModel.eraseToAnyPublisher(),
            $currentPage.eraseToAnyPublisher()
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (viewLearnToShareToolDomainModel: ViewLearnToShareToolDomainModel?, currentPage: Int) in
            
            guard let weakSelf = self, let domainModel = viewLearnToShareToolDomainModel else {
                return
            }
            
            let isOnLastPage: Bool = weakSelf.isOnLastPage
            
            weakSelf.continueTitle = isOnLastPage ? domainModel.interfaceStrings.startTrainingActionTitle : domainModel.interfaceStrings.nextTutorialItemActionTitle
        }
        .store(in: &cancellables)
        
        $currentPage
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { (currentPage: Int) in
                self.hidesBackButton = currentPage == 0
            }
            .store(in: &cancellables)
    }

    private var isOnFirstPage: Bool {
        return currentPage == 0
    }
    
    private var isOnLastPage: Bool {
        
        guard learnToShareToolItems.count > 0 else {
            return true
        }
        
        return currentPage >= learnToShareToolItems.count - 1
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
