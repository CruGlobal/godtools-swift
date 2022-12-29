//
//  LanguageSettingsFlow.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class LanguageSettingsFlow: Flow {
        
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        
        sharedNavigationController.pushViewController(getLanguageSettings(), animated: true)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .backTappedFromLanguageSettings:
            flowDelegate?.navigate(step: .languageSettingsFlowCompleted(state: .userClosedLanguageSettings))
            
        case .choosePrimaryLanguageTappedFromLanguageSettings:
            
            navigateToChooseLanguageView(chooseLanguageType: .primary)
                        
        case .chooseParallelLanguageTappedFromLanguageSettings:
            
            navigateToChooseLanguageView(chooseLanguageType: .parallel)
            
        case .backTappedFromChooseLanguage:
            
            navigationController.popViewController(animated: true)
            
        case .languageTappedFromChooseLanguage:
            
            navigationController.popViewController(animated: true)
            
        case .deleteLanguageTappedFromChooseLanguage:
            
            navigationController.popViewController(animated: true)
            
        default:
            break
        }
    }
    
    private func navigateToChooseLanguageView(chooseLanguageType: ChooseLanguageViewModel.ChooseLanguageType) {
        
        let view = getChooseLanguage(chooseLanguageType: chooseLanguageType)
                    
        navigationController.pushViewController(view, animated: true)
    }
}

extension LanguageSettingsFlow {
    
    func getLanguageSettings() -> UIViewController {
        
        let viewModel = LanguageSettingsViewModel(
            flowDelegate: self,
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            analytics: appDiContainer.dataLayer.getAnalytics()
        )
        
        let view = LanguageSettingsView(viewModel: viewModel)
        
        _ = view.addDefaultNavBackItem(
            target: viewModel,
            action: #selector(viewModel.backTapped)
        )
        
        return view
    }
    
    func getChooseLanguage(chooseLanguageType: ChooseLanguageViewModel.ChooseLanguageType) -> UIViewController {
        
        let viewModel = ChooseLanguageViewModel(
            flowDelegate: self,
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            userDidSetSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getUserDidSetSettingsPrimaryLanguageUseCase(),
            userDidSetSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getUserDidSetSettingsParallelLanguageUseCase(),
            userDidDeleteSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getUserDidDeleteSettingsParallelLanguageUseCase(),
            getSettingsLanguagesUseCase: appDiContainer.domainLayer.getSettingsLanguagesUseCase(),
            localizationServices: appDiContainer.localizationServices,
            analytics: appDiContainer.dataLayer.getAnalytics(),
            chooseLanguageType: chooseLanguageType
        )
        
        let view = ChooseLanguageView(viewModel: viewModel)
        
        _ = view.addDefaultNavBackItem(
            target: viewModel,
            action: #selector(viewModel.backTapped)
        )
        
        return view
    }
}
