//
//  ChooseAppLanguageFlow.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import SwiftUI

final class ChooseAppLanguageFlow: GTFlow {
    
    enum CompletedState: Sendable {
        case userChoseAppLanguage(appLanguage: AppLanguageListItemDomainModel)
        case userClosedChooseAppLanguage
    }
                
    init(appDiContainer: AppDiContainer) {
        
        let stepEmitter = FlowStepEmitter()
        
        super.init(
            appDiContainer: appDiContainer,
            initialView: Self.getAppLanguagesView(
                appDiContainer: appDiContainer,
                stepEmitter: stepEmitter
            ),
            stepEmitter: stepEmitter
        )
    }
    
    override func navigate(step: FlowStep) {
        
        guard let appStep = step as? AppFlowStep else {
            return
        }

        switch appStep {
            
        case .backTappedFromAppLanguages:
            completeFlow(state: .userClosedChooseAppLanguage)
            
        case .appLanguageTappedFromAppLanguages(let appLanguage):
                        
            presentView(
                view: getConfirmAppLanguageView(selectedLanguage: appLanguage),
                animated: true
            )
        
        case .appLanguageChangeConfirmed(let appLanguage):
            
            let setAppLanguageUseCase: SetAppLanguageUseCase = appDiContainer.feature.appLanguage.domainLayer.getSetAppLanguageUseCase()
                        
            Task {
                _ = try await setAppLanguageUseCase
                    .execute(appLanguage: appLanguage.language)
            }
            
            dismissView(animated: true)
            
            completeFlow(state: .userChoseAppLanguage(appLanguage: appLanguage))
                        
        case .nevermindTappedFromConfirmAppLanguageChange:
            dismissView(animated: true)
            
        case .backTappedFromConfirmAppLanguageChange:
            dismissView(animated: true)
            
        default:
            break
        }
    }
    
    private func completeFlow(state: CompletedState) {
        parent?.stepEmitter.emit(step: AppFlowStep.chooseAppLanguageFlowCompleted(state: state))
    }
}

extension ChooseAppLanguageFlow {
    
    private static func getAppLanguagesView(appDiContainer: AppDiContainer, stepEmitter: FlowStepEmitter) -> UIViewController {
        
        let viewModel = AppLanguagesViewModel(
            stepEmitter: stepEmitter,
            getAppLanguagesStringsUseCase: appDiContainer.feature.appLanguage.domainLayer.getAppLanguagesStringsUseCase(),
            searchAppLanguageInAppLanguagesListUseCase: appDiContainer.feature.appLanguage.domainLayer.getSearchAppLanguageInAppLanguagesListUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getAppLanguagesListUseCase: appDiContainer.feature.appLanguage.domainLayer.getAppLanguagesListUseCase(),
            getSearchBarStringsUseCase: appDiContainer.core.domainLayer.getSearchBarStringsUseCase()
        )
        
        let view = AppLanguagesView(viewModel: viewModel)
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped),
            accessibilityIdentifier: AccessibilityStrings.Button.appLanguagesNavBack.id
        )
        
        let hostingView = AppHostingController<AppLanguagesView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: backButton,
                leadingItems: [],
                trailingItems: []
            )
        )
        
        return hostingView
    }
    
    private func getConfirmAppLanguageView(selectedLanguage: AppLanguageListItemDomainModel) -> UIViewController {
        
        let viewModel = ConfirmAppLanguageViewModel(
            stepEmitter: stepEmitter,
            selectedLanguage: selectedLanguage,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getConfirmAppLanguageStringsUseCase: appDiContainer.feature.appLanguage.domainLayer.getConfirmAppLanguageStringsUseCase()
        )
        
        let view = ConfirmAppLanguageView(viewModel: viewModel)
        
        let hostingView = AppHostingController<ConfirmAppLanguageView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: nil,
                leadingItems: [],
                trailingItems: []
            )
        )
        
        return hostingView
    }
}
