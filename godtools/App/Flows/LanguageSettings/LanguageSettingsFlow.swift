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
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: AppNavigationController, deepLink: ParsedDeepLinkType?) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        
        let initialView: UIViewController = getLanguageSettingsView()
            
        if deepLink == .appLanguagesList {
            
            sharedNavigationController.pushViewController(initialView, animated: false)
            
            navigateToChooseAppLanguageFlow(animated: false)
        }
        else {
            
            sharedNavigationController.pushViewController(initialView, animated: true)
        }
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .backTappedFromLanguageSettings:
            flowDelegate?.navigate(step: .languageSettingsFlowCompleted(state: .userClosedLanguageSettings))
            
        case .chooseAppLanguageTappedFromLanguageSettings:
            navigateToChooseAppLanguageFlow()
            
        case .chooseAppLanguageFlowCompleted(let state):
            navigateBackFromChooseAppLanguageFlow()
        
        case .editDownloadedLanguagesTappedFromLanguageSettings:
            navigationController.pushViewController(getDownloadableLanguagesView(), animated: true)
            
        case .backTappedFromDownloadedLanguages:
            navigationController.popViewController(animated: true)
            
        case .showLanguageDownloadErrorAlert(let error):
            let alertView = getLanguageDownloadErrorAlertView(error: error)
            navigationController.present(alertView, animated: true)
            
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
            viewLanguageSettingsUseCase: appDiContainer.feature.appLanguage.domainLayer.getViewLanguageSettingsUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase()
        )
        
        let view = LanguageSettingsView(viewModel: viewModel)
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped),
            accessibilityIdentifier: nil
        )
        
        let hostingView = AppHostingController<LanguageSettingsView>(
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
    
    func getDownloadableLanguagesView() -> UIViewController {
        
        let viewModel = DownloadableLanguagesViewModel(
            flowDelegate: self,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewDownloadableLanguagesUseCase: appDiContainer.feature.appLanguage.domainLayer.getViewDownloadableLanguagesUseCase(),
            viewSearchBarUseCase: appDiContainer.domainLayer.getViewSearchBarUseCase(), searchLanguageInDownloadableLanguagesUseCase: appDiContainer.feature.appLanguage.domainLayer.getSearchLanguageInDownloadableLanguagesUseCase(),
            downloadToolLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getDownloadToolLanguageUseCase(),
            removeDownloadedToolLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getRemoveDownloadedToolLanguageUseCase()
        )
        
        let view = DownloadableLanguagesView(viewModel: viewModel)
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped),
            accessibilityIdentifier: nil
        )
        
        let hostingView = AppHostingController<DownloadableLanguagesView>(
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
    
    func getLanguageDownloadErrorAlertView(error: Error) -> UIViewController {
        
        let viewModel = LanguageDownloadErrorAlertViewModel(error: error)
        let view = LanguageDownloadErrorAlertView(viewModel: viewModel)
        
        return view.controller
    }
}
