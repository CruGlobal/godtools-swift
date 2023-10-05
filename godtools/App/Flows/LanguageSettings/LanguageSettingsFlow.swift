//
//  LanguageSettingsFlow.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

class LanguageSettingsFlow: Flow, ChooseAppLanguageNavigationFlow {
        
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    var chooseAppLanguageFlow: ChooseAppLanguageFlow?
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: AppNavigationController) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        
        sharedNavigationController.pushViewController(getLanguageSettingsView(), animated: true)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .backTappedFromLanguageSettings:
            flowDelegate?.navigate(step: .languageSettingsFlowCompleted(state: .userClosedLanguageSettings))
            
        case .chooseAppLanguageTappedFromLanguageSettings:
            navigateToChooseAppLanguageFlow()
            
        case .chooseAppLanguageFlowCompleted(let state):
            navigateBackFromChooseAppLanguageFlow()
            
        default:
            break
        }
    }
}

extension LanguageSettingsFlow {
    
    func getLanguageSettingsView() -> UIViewController {
        
        let viewModel = LanguageSettingsViewModel(
            flowDelegate: self,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getAppLanguageNameInAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getAppLanguageNameInAppLanguageUseCase(),
            getInterfaceStringInAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getInterfaceStringInAppLanguageUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase()
        )
        
        let view = LanguageSettingsView(viewModel: viewModel)
        
        let hostingView = AppHostingController<LanguageSettingsView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                backButton: AppBackBarItem(target: viewModel, action: #selector(viewModel.backTapped)),
                leadingItems: [],
                trailingItems: []
            )
        )

        return hostingView
    }
}
