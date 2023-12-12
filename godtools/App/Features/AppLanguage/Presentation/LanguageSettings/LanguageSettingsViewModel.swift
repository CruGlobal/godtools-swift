//
//  LanguageSettingsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class LanguageSettingsViewModel: ObservableObject {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let viewLanguageSettingsUseCase: ViewLanguageSettingsUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    
    private var cancellables = Set<AnyCancellable>()
        
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = ""
    
    @Published var navTitle: String = ""
    @Published var appInterfaceLanguageTitle: String = "App "
    @Published var numberOfLanguagesAvailable: String = "Number of languages available need to implement."
    @Published var setLanguageYouWouldLikeAppDisplayedInLabel: String = "Set the language you'd like the whole app displayed in."
    @Published var appInterfaceLanguageButtonTitle: String = ""
    @Published var toolLanguagesAvailableOfflineTitle: String = ""
    @Published var downloadToolsForOfflineMessage: String = ""
    @Published var editDownloadedLanguagesButtonTitle: String = ""
    
    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, viewLanguageSettingsUseCase: ViewLanguageSettingsUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.viewLanguageSettingsUseCase = viewLanguageSettingsUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        
        getCurrentAppLanguageUseCase.getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage.eraseToAnyPublisher()
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewLanguageSettingsDomainModel, Never> in
                
                return self.viewLanguageSettingsUseCase
                    .viewPublisher(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: ViewLanguageSettingsDomainModel) in
                
                let interfaceStrings: LanguageSettingsInterfaceStringsDomainModel = domainModel.interfaceStrings
                
                self?.navTitle = interfaceStrings.navTitle
                self?.appInterfaceLanguageTitle = interfaceStrings.appInterfaceLanguageTitle
                self?.setLanguageYouWouldLikeAppDisplayedInLabel = interfaceStrings.setAppLanguageMessage
                self?.appInterfaceLanguageButtonTitle = interfaceStrings.chooseAppLanguageButtonTitle
                self?.toolLanguagesAvailableOfflineTitle = interfaceStrings.toolLanguagesAvailableOfflineTitle
                self?.downloadToolsForOfflineMessage = interfaceStrings.downloadToolsForOfflineMessage
                self?.editDownloadedLanguagesButtonTitle = interfaceStrings.editDownloadedLanguagesButtonTitle
                
            }
            .store(in: &cancellables)
    }
}

// MARK: - Inputs

extension LanguageSettingsViewModel {
    
    @objc func backTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromLanguageSettings)
    }
    
    func chooseAppLanguageTapped() {
        
        flowDelegate?.navigate(step: .chooseAppLanguageTappedFromLanguageSettings)
    }
    
    func editDownloadedLanguagesTapped() {
        
        flowDelegate?.navigate(step: .editDownloadedLanguagesTappedFromLanguageSettings)
    }
    
    func pageViewed() {
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            screenName: "Language Settings",
            siteSection: "menu",
            siteSubSection: "",
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
    }
}
