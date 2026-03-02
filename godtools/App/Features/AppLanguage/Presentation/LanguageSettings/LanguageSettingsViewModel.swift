//
//  LanguageSettingsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class LanguageSettingsViewModel: ObservableObject {
    
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getLanguageSettingsStringsUseCase: GetLanguageSettingsStringsUseCase
    private let getDownloadedLanguagesListUseCase: GetDownloadedLanguagesListUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    
    private var cancellables = Set<AnyCancellable>()
        
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = ""
    
    @Published private(set) var strings = LanguageSettingsStringsDomainModel.emptyValue
    
    @Published var downloadedLanguages: [DownloadedLanguageListItemDomainModel] = []
    
    init(flowDelegate: FlowDelegate, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getLanguageSettingsStringsUseCase: GetLanguageSettingsStringsUseCase, getDownloadedLanguagesListUseCase: GetDownloadedLanguagesListUseCase, trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase) {
        
        self.flowDelegate = flowDelegate
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getLanguageSettingsStringsUseCase = getLanguageSettingsStringsUseCase
        self.getDownloadedLanguagesListUseCase = getDownloadedLanguagesListUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getLanguageSettingsStringsUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (strings: LanguageSettingsStringsDomainModel) in
                              
                self?.strings = strings
            })
            .store(in: &cancellables)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                getDownloadedLanguagesListUseCase
                    .execute(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (downloadedLanguages: [DownloadedLanguageListItemDomainModel]) in
                                
                self?.downloadedLanguages = downloadedLanguages
            })
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
            appLanguage: appLanguage,
            contentLanguage: nil,
            contentLanguageSecondary: nil
        )
    }
}
