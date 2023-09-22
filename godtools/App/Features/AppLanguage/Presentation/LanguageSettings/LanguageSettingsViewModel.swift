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

    private let getAppLanguageUseCase: GetAppLanguageUseCase
    private let getInterfaceStringUseCase: GetInterfaceStringUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let didChooseAppLanguageSubject: PassthroughSubject<AppLanguageDomainModel, Never> = PassthroughSubject()
    
    private var currentAppLanguage: AppLanguageDomainModel? {
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
    
    init(flowDelegate: FlowDelegate, getAppLanguageUseCase: GetAppLanguageUseCase, getInterfaceStringUseCase: GetInterfaceStringUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getAppLanguageUseCase = getAppLanguageUseCase
        self.getInterfaceStringUseCase = getInterfaceStringUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        
        getAppLanguageUseCase.getAppLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (appLanguage: AppLanguageDomainModel) in
                self?.currentAppLanguage = appLanguage
            }
            .store(in: &cancellables)
        
        didChooseAppLanguageSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (appLanguage: AppLanguageDomainModel) in
                self?.currentAppLanguage = appLanguage
            }
            .store(in: &cancellables)
        
        getInterfaceStringUseCase.getStringPublisher(id: "language_settings")
            .receive(on: DispatchQueue.main)
            .assign(to: \.navTitle, on: self)
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
