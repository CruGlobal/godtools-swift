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
    @Published var appInterfaceLanguageTitle: String = " "
    @Published var numberOfLanguagesAvailable: String = ""
    @Published var setLanguageYouWouldLikeAppDisplayedInLabel: String = ""
    @Published var appInterfaceLanguageButtonTitle: String = ""
    @Published var toolLanguagesAvailableOfflineTitle: String = ""
    @Published var downloadToolsForOfflineMessage: String = ""
    @Published var editDownloadedLanguagesButtonTitle: String = ""
    @Published var downloadedLanguages: [DownloadedLanguageListItemDomainModel] = []
    
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
                
                return viewLanguageSettingsUseCase
                    .viewPublisher(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: ViewLanguageSettingsDomainModel) in
                
                let interfaceStrings: LanguageSettingsInterfaceStringsDomainModel = domainModel.interfaceStrings
                
                self?.navTitle = interfaceStrings.navTitle
                self?.appInterfaceLanguageTitle = interfaceStrings.appInterfaceLanguageTitle
                self?.numberOfLanguagesAvailable = interfaceStrings.numberOfAppLanguagesAvailable
                self?.setLanguageYouWouldLikeAppDisplayedInLabel = interfaceStrings.setAppLanguageMessage
                self?.appInterfaceLanguageButtonTitle = interfaceStrings.chooseAppLanguageButtonTitle
                self?.toolLanguagesAvailableOfflineTitle = interfaceStrings.toolLanguagesAvailableOfflineTitle
                self?.downloadToolsForOfflineMessage = interfaceStrings.downloadToolsForOfflineMessage
                self?.editDownloadedLanguagesButtonTitle = interfaceStrings.editDownloadedLanguagesButtonTitle
                
                self?.downloadedLanguages = domainModel.downloadedLanguages
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
