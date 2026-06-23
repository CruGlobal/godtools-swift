//
//  LocalizationSettingsConfirmationViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 2/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class LocalizationSettingsConfirmationViewModel: ObservableObject {

    private let stepEmitter: FlowStepEmitter
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getLocalizationSettingsConfirmationStringsUseCase: GetLocalizationSettingsConfirmationStringsUseCase
    private let selectedCountry: LocalizationSettingsCountryListItem
    
    private var cancellables: Set<AnyCancellable> = Set()

    @Published private(set) var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private(set) var strings = LocalizationSettingsConfirmationStringsDomainModel.emptyValue

    init(
        stepEmitter: FlowStepEmitter,
        selectedCountry: LocalizationSettingsCountryListItem,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getLocalizationSettingsConfirmationStringsUseCase: GetLocalizationSettingsConfirmationStringsUseCase
    ) {

        self.stepEmitter = stepEmitter
        self.selectedCountry = selectedCountry
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getLocalizationSettingsConfirmationStringsUseCase = getLocalizationSettingsConfirmationStringsUseCase

        getCurrentAppLanguageUseCase
            .execute()
            .assign(to: &$appLanguage)

        $appLanguage
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .map { appLanguage in
                
                return getLocalizationSettingsConfirmationStringsUseCase
                    .execute(
                        appLanguage: appLanguage,
                        selectedCountry: selectedCountry
                    )
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .assign(to: &$strings)
    }

    deinit {
        print("x deinit: \(type(of: self))")
    }
}

// MARK: - Inputs

extension LocalizationSettingsConfirmationViewModel {

    func closeTapped() {
        stepEmitter.emit(step: AppFlowStep.closeTappedFromLocalizationConfirmation)
    }

    func cancelTapped() {
        stepEmitter.emit(step: AppFlowStep.cancelTappedFromLocalizationConfirmation)
    }

    func confirmTapped() {
        stepEmitter.emit(step: AppFlowStep.confirmTappedFromLocalizationConfirmation(country: selectedCountry))
    }
}
