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
    private let getLanguageSettingsInterfaceStringsUseCase: GetLanguageSettingsInterfaceStringsUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    
    private var cancellables = Set<AnyCancellable>()
        
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageCodeDomainModel = ""
    
    @Published var navTitle: String = ""
    @Published var appInterfaceLanguageTitle: String = "App "
    @Published var numberOfLanguagesAvailable: String = "Number of languages available need to implement."
    @Published var setLanguageYouWouldLikeAppDisplayedInLabel: String = "Set the language you'd like the whole app displayed in."
    @Published var appInterfaceLanguageButtonTitle: String = ""
    
    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getLanguageSettingsInterfaceStringsUseCase: GetLanguageSettingsInterfaceStringsUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getLanguageSettingsInterfaceStringsUseCase = getLanguageSettingsInterfaceStringsUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        
        getCurrentAppLanguageUseCase.getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        getLanguageSettingsInterfaceStringsUseCase.getStringsPublisher(appLanguagePublisher: $appLanguage.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (interfaceStrings: LanguageSettingsInterfaceStringsDomainModel) in
                
                self?.navTitle = interfaceStrings.navTitle
                self?.appInterfaceLanguageTitle = interfaceStrings.appInterfaceLanguageTitle
                self?.setLanguageYouWouldLikeAppDisplayedInLabel = interfaceStrings.setAppLanguageMessage
                self?.appInterfaceLanguageButtonTitle = interfaceStrings.chooseAppLanguageButtonTitle
                
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
