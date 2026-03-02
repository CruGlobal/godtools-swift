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
    
    @Published private var appLanguage: AppLanguageDomainModel = ""
    
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
        
        appDiContainer.feature.appLanguage.domainLayer
            .getCurrentAppLanguageUseCase()
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
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
            
        case .chooseAppLanguageFlowCompleted( _):
            navigateBackFromChooseAppLanguageFlow()
        
        case .editDownloadedLanguagesTappedFromLanguageSettings:
            navigationController.pushViewController(getDownloadableLanguagesView(), animated: true)
            
        case .backTappedFromDownloadedLanguages:
            navigationController.popViewController(animated: true)
            
        case .languageDownloadFailedFromDownloadedLanguages(let error):
            presentError(appLanguage: appLanguage, error: error)
            
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
            getLanguageSettingsStringsUseCase: appDiContainer.feature.appLanguage.domainLayer.getLanguageSettingsStringsUseCase(),
            getDownloadedLanguagesListUseCase: appDiContainer.feature.appLanguage.domainLayer.getDownloadedLanguagesListUseCase(),
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
            getDownloadableLanguagesStringsUseCase: appDiContainer.feature.appLanguage.domainLayer.getDownloadableLanguagesStringsUseCase(),
            getDownloadableLanguagesListUseCase: appDiContainer.feature.appLanguage.domainLayer.getDownloadableLanguagesListUseCase(),
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
}
