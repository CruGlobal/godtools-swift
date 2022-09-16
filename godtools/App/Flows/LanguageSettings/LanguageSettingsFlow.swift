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
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        
        let viewModel = LanguageSettingsViewModel(
            flowDelegate: self,
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices(),
            analytics: appDiContainer.analytics
        )
        
        let view = LanguageSettingsView(viewModel: viewModel)
        
        sharedNavigationController.pushViewController(view, animated: true)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .choosePrimaryLanguageTappedFromLanguageSettings:
            
            navigateToChooseLanguageView(chooseLanguageType: .primary)
                        
        case .chooseParallelLanguageTappedFromLanguageSettings:
            
            navigateToChooseLanguageView(chooseLanguageType: .parallel)
            
        case .languageTappedFromChooseLanguage:
            
            navigationController.popViewController(animated: true)
            
        case .deleteLanguageTappedFromChooseLanguage:
            
            navigationController.popViewController(animated: true)
            
        default:
            break
        }
    }
    
    private func navigateToChooseLanguageView(chooseLanguageType: ChooseLanguageViewModel.ChooseLanguageType) {
        
        let viewModel = ChooseLanguageViewModel(
            flowDelegate: self,
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            userDidSetSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getUserDidSetSettingsPrimaryLanguageUseCase(),
            userDidSetSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getUserDidSetSettingsParallelLanguageUseCase(),
            userDidDeleteSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getUserDidDeleteSettingsParallelLanguageUseCase(),
            getSettingsLanguagesUseCase: appDiContainer.domainLayer.getSettingsLanguagesUseCase(),
            localizationServices: appDiContainer.localizationServices,
            analytics: appDiContainer.analytics,
            chooseLanguageType: chooseLanguageType
        )
        let view = ChooseLanguageView(viewModel: viewModel)
                    
        navigationController.pushViewController(view, animated: true)
    }
}
