//
//  LearnToShareToolViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class LearnToShareToolViewModel: ObservableObject {
    
    private let toolId: String
    private let toolPrimaryLanguage: AppLanguageDomainModel
    private let toolParallelLanguage: AppLanguageDomainModel?
    private let toolSelectedLanguageIndex: Int?
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getLearnToShareToolStringsUseCase: GetLearnToShareToolStringsUseCase
    private let getLearnToShareToolTutorialUseCase: GetLearnToShareToolTutorialUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue

    @Published private(set) var strings = LearnToShareToolStringsDomainModel.emptyValue
    @Published private(set) var continueButtonAccessibility: AccessibilityStrings.Button = .continueForward
    @Published private(set) var hidesBackButton: Bool = true
    @Published private(set) var learnToShareToolItems: [LearnToShareToolItemDomainModel] = Array()
    @Published private(set) var continueTitle: String = ""
    
    @Published var currentPage: Int = 0
    
    init(flowDelegate: FlowDelegate, toolId: String, toolPrimaryLanguage: AppLanguageDomainModel, toolParallelLanguage: AppLanguageDomainModel?, toolSelectedLanguageIndex: Int?, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getLearnToShareToolStringsUseCase: GetLearnToShareToolStringsUseCase, getLearnToShareToolTutorialUseCase: GetLearnToShareToolTutorialUseCase) {
        
        self.flowDelegate = flowDelegate
        self.toolId = toolId
        self.toolPrimaryLanguage = toolPrimaryLanguage
        self.toolParallelLanguage = toolParallelLanguage
        self.toolSelectedLanguageIndex = toolSelectedLanguageIndex
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getLearnToShareToolStringsUseCase = getLearnToShareToolStringsUseCase
        self.getLearnToShareToolTutorialUseCase = getLearnToShareToolTutorialUseCase
              
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getLearnToShareToolStringsUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (strings: LearnToShareToolStringsDomainModel) in
                
                self?.strings = strings
            }
            .store(in: &cancellables)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getLearnToShareToolTutorialUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (tutorial: [LearnToShareToolItemDomainModel]) in
                
                self?.learnToShareToolItems = tutorial
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            $strings.dropFirst(),
            $currentPage
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] (strings: LearnToShareToolStringsDomainModel, currentPage: Int) in
            
            guard let weakSelf = self else {
                return
            }
            
            let isOnLastPage: Bool = weakSelf.isOnLastPage
            
            weakSelf.continueTitle = isOnLastPage ? strings.startTrainingActionTitle : strings.nextTutorialItemActionTitle
            weakSelf.continueButtonAccessibility = isOnLastPage ? .startTraining : .continueForward
        }
        .store(in: &cancellables)
        
        $currentPage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (currentPage: Int) in
                self?.hidesBackButton = currentPage == 0
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
        
        currentPage -= 1
    }
    
    @objc func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromLearnToShareTool(toolId: toolId, primaryLanguage: toolPrimaryLanguage, parallelLanguage: toolParallelLanguage, selectedLanguageIndex: toolSelectedLanguageIndex))
    }
    
    func continueTapped() {
        
        if isOnLastPage {
            flowDelegate?.navigate(step: .startTrainingTappedFromLearnToShareTool(toolId: toolId, primaryLanguage: toolPrimaryLanguage, parallelLanguage: toolParallelLanguage, selectedLanguageIndex: toolSelectedLanguageIndex))
        }
        else {
            currentPage += 1
        }
    }
}
