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
            languageSettingsService: appDiContainer.languageSettingsService,
            analytics: appDiContainer.analytics
        )
        let view = LanguageSettingsView(viewModel: viewModel)
        
        sharedNavigationController.pushViewController(view, animated: true)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .choosePrimaryLanguageTappedFromLanguageSettings:
            
            let viewModel = ChooseLanguageViewModel(
                flowDelegate: self,
                dataDownloader: appDiContainer.initialDataDownloader,
                languageSettingsService: appDiContainer.languageSettingsService,
                analytics: appDiContainer.analytics,
                chooseLanguageType: .primary
            )
            let view = ChooseLanguageView(viewModel: viewModel)
            
            navigationController.pushViewController(view, animated: true)
                        
        case .chooseParallelLanguageTappedFromLanguageSettings:
            
            let viewModel = ChooseLanguageViewModel(
                flowDelegate: self,
                dataDownloader: appDiContainer.initialDataDownloader,
                languageSettingsService: appDiContainer.languageSettingsService,
                analytics: appDiContainer.analytics,
                chooseLanguageType: .parallel
            )
            let view = ChooseLanguageView(viewModel: viewModel)
                        
            navigationController.pushViewController(view, animated: true)
            
        case .languageTappedFromChooseLanguage:
            
            navigationController.popViewController(animated: true)
            
        case .deleteLanguageTappedFromChooseLanguage:
            
            navigationController.popViewController(animated: true)
            
        default:
            break
        }
    }
}
