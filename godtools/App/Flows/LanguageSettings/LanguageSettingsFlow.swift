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
import Flow

final class LanguageSettingsFlow: GTFlow {
    
    enum CompletedState {
        case userClosed
    }
                
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
        
    init(appDiContainer: AppDiContainer) {
                
        let stepEmitter = FlowStepEmitter()
        
        super.init(
            appDiContainer: appDiContainer,
            initialView: Self.getLanguageSettings(
                appDiContainer: appDiContainer,
                stepEmitter: stepEmitter
            ),
            stepEmitter: stepEmitter
        )
        
        appDiContainer.feature.appLanguage.domainLayer
            .getCurrentAppLanguageUseCase()
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
    }
    
    override func navigate(step: FlowStep) {
        
        guard let appStep = step as? AppFlowStep else {
            return
        }

        switch appStep {
            
        case .backTappedFromLanguageSettings:
            completeFlow(state: .userClosed)
            
        case .chooseAppLanguageTappedFromLanguageSettings:
            pushFlow(
                flow: ChooseAppLanguageFlow(appDiContainer: appDiContainer),
                animated: true
            )
            
        case .chooseAppLanguageFlowCompleted( _):
            popFlow()
        
        case .editDownloadedLanguagesTappedFromLanguageSettings:
            navigationController.pushViewController(getDownloadableLanguagesView(), animated: true)
            
        case .backTappedFromDownloadedLanguages:
            navigationController.popViewController(animated: true)
            
        default:
            break
        }
    }
    
    private func completeFlow(state: CompletedState) {
        parent?.stepEmitter.emit(step: AppFlowStep.languageSettingsFlowCompleted(state: state))
    }
}

extension LanguageSettingsFlow {
    
    private static func getLanguageSettings(appDiContainer: AppDiContainer, stepEmitter: FlowStepEmitter) -> UIViewController {
        
        let viewModel = LanguageSettingsViewModel(
            stepEmitter: stepEmitter,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getLanguageSettingsStringsUseCase: appDiContainer.feature.appLanguage.domainLayer.getLanguageSettingsStringsUseCase(),
            getDownloadedLanguagesListUseCase: appDiContainer.feature.appLanguage.domainLayer.getDownloadedLanguagesListUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase()
        )
        
        let view = LanguageSettingsView(viewModel: viewModel)
        
        let hostingView = AppHostingController<LanguageSettingsView>(
            rootView: view
        )
        
        return hostingView
    }
    
    private func getDownloadableLanguagesView() -> UIViewController {
        
        let viewModel = DownloadableLanguagesViewModel(
            stepEmitter: stepEmitter,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getDownloadableLanguagesStringsUseCase: appDiContainer.feature.appLanguage.domainLayer.getDownloadableLanguagesStringsUseCase(),
            getDownloadableLanguagesListUseCase: appDiContainer.feature.appLanguage.domainLayer.getDownloadableLanguagesListUseCase(),
            getSearchBarStringsUseCase: appDiContainer.core.domainLayer.getSearchBarStringsUseCase(), searchLanguageInDownloadableLanguagesUseCase: appDiContainer.feature.appLanguage.domainLayer.getSearchLanguageInDownloadableLanguagesUseCase(),
            downloadToolLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getDownloadToolLanguageUseCase(),
            removeDownloadedToolLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getRemoveDownloadedToolLanguageUseCase()
        )
        
        let view = DownloadableLanguagesView(viewModel: viewModel)
        
        let hostingView = AppHostingController<DownloadableLanguagesView>(
            rootView: view
        )
        
        return hostingView
    }
}
