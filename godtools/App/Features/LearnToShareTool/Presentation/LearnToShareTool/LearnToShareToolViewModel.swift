//
//  LearnToShareToolViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class LearnToShareToolViewModel: ObservableObject {
    
    private let stepEmitter: FlowStepEmitter
    private let tool: ToolDetailsTool
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getLearnToShareToolStringsUseCase: GetLearnToShareToolStringsUseCase
    private let getLearnToShareToolTutorialUseCase: GetLearnToShareToolTutorialUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
        
    @Published private var appLanguage = AppLanguageDomainModel.english

    @Published private(set) var strings = LearnToShareToolStringsDomainModel.emptyValue
    @Published private(set) var continueButtonAccessibility: AccessibilityStrings.Button = .continueForward
    @Published private(set) var hidesBackButton: Bool = true
    @Published private(set) var learnToShareToolItems: [LearnToShareToolItemDomainModel] = Array()
    @Published private(set) var continueTitle: String = ""
    
    @Published var currentPage: Int = 0
    
    init(
        stepEmitter: FlowStepEmitter,
        tool: ToolDetailsTool,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getLearnToShareToolStringsUseCase: GetLearnToShareToolStringsUseCase,
        getLearnToShareToolTutorialUseCase: GetLearnToShareToolTutorialUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.tool = tool
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getLearnToShareToolStringsUseCase = getLearnToShareToolStringsUseCase
        self.getLearnToShareToolTutorialUseCase = getLearnToShareToolTutorialUseCase
              
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (appLanguage: AppLanguageDomainModel) in

                self?.appLanguage = appLanguage
                self?.didSetAppLanguage(appLanguage: appLanguage)
            })
            .store(in: &cancellables)

        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                return AnyPublisher() {
                    await getLearnToShareToolTutorialUseCase
                        .execute(appLanguage: appLanguage)
                }
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

    private func didSetAppLanguage(appLanguage: AppLanguageDomainModel) {

        strings = getLearnToShareToolStringsUseCase
            .execute(appLanguage: appLanguage)
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
        stepEmitter.emit(
            step: AppFlowStep.closeTappedFromLearnToShareTool(tool: tool)
        )
    }
    
    func continueTapped() {
        
        if isOnLastPage {
            stepEmitter.emit(
                step: AppFlowStep.startTrainingTappedFromLearnToShareTool(tool: tool)
            )
        }
        else {
            currentPage += 1
        }
    }
}
