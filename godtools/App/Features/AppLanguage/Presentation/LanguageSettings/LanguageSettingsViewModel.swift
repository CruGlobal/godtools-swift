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

    private static var currentLanguage: AppLanguageListItemDomainModel? // TODO: Remove once appLanguage is being persisted. ~Levi
    
    private let getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let didChooseAppLanguageSubject: PassthroughSubject<AppLanguageListItemDomainModel, Never> = PassthroughSubject()
    
    private var currentAppLanguage: AppLanguageListItemDomainModel? {
        didSet {
            didSetCurrentAppLanguage()
        }
    }
    private var cancellables = Set<AnyCancellable>()
        
    private weak var flowDelegate: FlowDelegate?
    
    @Published var navTitle: String = ""
    @Published var appInterfaceLanguageTitle: String = "App "
    @Published var numberOfLanguagesAvailable: String = "Number of languages available need to implement."
    @Published var setLanguageYouWouldLikeAppDisplayedInLabel: String = "Set the language you'd like the whole app displayed in."
    @Published var appInterfaceLanguageButtonTitle: String = "English"
    
    init(flowDelegate: FlowDelegate, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        
        navTitle = getInterfaceStringInAppLanguageUseCase.getString(id: "language_settings")
        
        didChooseAppLanguageSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (appLanguage: AppLanguageListItemDomainModel) in
                self?.currentAppLanguage = appLanguage
                LanguageSettingsViewModel.currentLanguage = appLanguage // TODO: Remove once appLanguage is being persisted. ~Levi
            }
            .store(in: &cancellables)
    }
    
    private func didSetCurrentAppLanguage() {
        appInterfaceLanguageButtonTitle = "Language Code: \(currentAppLanguage?.languageCode ?? "")"
    }
}

// MARK: - Inputs

extension LanguageSettingsViewModel {
    
    @objc func backTapped() {
        
        flowDelegate?.navigate(step: .backTappedFromLanguageSettings)
    }
    
    func chooseAppLanguageTapped() {
        
        flowDelegate?.navigate(step: .chooseAppLanguageTappedFromLanguageSettings(didChooseAppLanguageSubject: didChooseAppLanguageSubject))
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
