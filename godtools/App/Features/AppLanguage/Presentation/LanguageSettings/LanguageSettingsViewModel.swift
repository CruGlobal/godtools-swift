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
    private let getAppLanguageNameInAppLanguageUseCase: GetAppLanguageNameInAppLanguageUseCase
    private let getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    
    private var cancellables = Set<AnyCancellable>()
        
    private weak var flowDelegate: FlowDelegate?
    
    @Published var navTitle: String = ""
    @Published var appInterfaceLanguageTitle: String = "App "
    @Published var numberOfLanguagesAvailable: String = "Number of languages available need to implement."
    @Published var setLanguageYouWouldLikeAppDisplayedInLabel: String = "Set the language you'd like the whole app displayed in."
    @Published var appInterfaceLanguageButtonTitle: String = ""
    
    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getAppLanguageNameInAppLanguageUseCase: GetAppLanguageNameInAppLanguageUseCase, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getAppLanguageNameInAppLanguageUseCase = getAppLanguageNameInAppLanguageUseCase
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        
        getInterfaceStringInAppLanguageUseCase.observeStringChangedPublisher(id: AppLanguageStringKeys.LanguageSettings.navTitle.rawValue)
            .receive(on: DispatchQueue.main)
            .assign(to: &$navTitle)
        
        
        getCurrentAppLanguageUseCase.observeLanguageChangedPublisher()
            .flatMap({ (currentAppLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<AppLanguageNameDomainModel, Never> in
                
                return self.getAppLanguageNameInAppLanguageUseCase.getLanguageNamePublisher(language: currentAppLanguage)
                    .eraseToAnyPublisher()
            })
            .map { (appLanguageName: AppLanguageNameDomainModel) in
                appLanguageName.value
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$appInterfaceLanguageButtonTitle)
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
