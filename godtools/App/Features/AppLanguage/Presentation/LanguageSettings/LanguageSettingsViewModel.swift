//
//  LanguageSettingsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class LanguageSettingsViewModel: ObservableObject {
    
    private let stepEmitter: FlowStepEmitter
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getLanguageSettingsStringsUseCase: GetLanguageSettingsStringsUseCase
    private let getDownloadedLanguagesListUseCase: GetDownloadedLanguagesListUseCase
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    
    private var cancellables = Set<AnyCancellable>()
            
    @Published private var appLanguage: AppLanguageDomainModel = ""
    
    @Published private(set) var strings = LanguageSettingsStringsDomainModel.emptyValue
    
    @Published var downloadedLanguages: [DownloadedLanguageListItemDomainModel] = []
    
    init(
        stepEmitter: FlowStepEmitter,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getLanguageSettingsStringsUseCase: GetLanguageSettingsStringsUseCase,
        getDownloadedLanguagesListUseCase: GetDownloadedLanguagesListUseCase,
        trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getLanguageSettingsStringsUseCase = getLanguageSettingsStringsUseCase
        self.getDownloadedLanguagesListUseCase = getDownloadedLanguagesListUseCase
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (appLanguage: AppLanguageDomainModel) in
                self?.appLanguage = appLanguage
                self?.didSetApplanguage(appLanguage: appLanguage)
            }
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
    
    private func didSetApplanguage(appLanguage: AppLanguageDomainModel) {

        Task {

            strings = await getLanguageSettingsStringsUseCase
                .execute(appLanguage: appLanguage)
        }
    }
}

// MARK: - Inputs

extension LanguageSettingsViewModel {
    
    @objc func backTapped() {
        
        stepEmitter.emit(step: AppFlowStep.backTappedFromLanguageSettings)
    }
    
    func chooseAppLanguageTapped() {
        
        stepEmitter.emit(step: AppFlowStep.chooseAppLanguageTappedFromLanguageSettings)
    }
    
    func editDownloadedLanguagesTapped() {
        
        stepEmitter.emit(step: AppFlowStep.editDownloadedLanguagesTappedFromLanguageSettings)
    }
    
    func pageViewed() {
        
        trackScreenViewAnalyticsUseCase.trackScreen(
            properties: AnalyticsProperties(
                screenName: "Language Settings",
                siteSection: "menu",
                siteSubSection: "",
                appLanguage: appLanguage,
                contentLanguage: nil,
                secondaryContentLanguage: nil
            )
        )
    }
}
