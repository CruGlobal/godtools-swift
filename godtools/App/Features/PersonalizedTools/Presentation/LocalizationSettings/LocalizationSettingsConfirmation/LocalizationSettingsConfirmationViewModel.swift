//
//  LocalizationSettingsConfirmationViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 2/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class LocalizationSettingsConfirmationViewModel: ObservableObject {

    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getLocalizationSettingsConfirmationStringsUseCase: GetLocalizationSettingsConfirmationStringsUseCase
    private let selectedCountry: LocalizationSettingsCountryListItemDomainModel
    
    private var cancellables: Set<AnyCancellable> = Set()
    private weak var flowDelegate: FlowDelegate?

    @Published private(set) var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private(set) var strings = LocalizationSettingsConfirmationStringsDomainModel.emptyValue

    init(flowDelegate: FlowDelegate, selectedCountry: LocalizationSettingsCountryListItemDomainModel, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getLocalizationSettingsConfirmationStringsUseCase: GetLocalizationSettingsConfirmationStringsUseCase) {

        self.flowDelegate = flowDelegate
        self.selectedCountry = selectedCountry
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getLocalizationSettingsConfirmationStringsUseCase = getLocalizationSettingsConfirmationStringsUseCase

        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)

        $appLanguage
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .map { appLanguage in
                
                return getLocalizationSettingsConfirmationStringsUseCase.execute(appLanguage: appLanguage, selectedCountry: selectedCountry)
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
        flowDelegate?.navigate(step: .closeTappedFromLocalizationConfirmation)
    }

    func cancelTapped() {
        flowDelegate?.navigate(step: .cancelTappedFromLocalizationConfirmation)
    }

    func confirmTapped() {
        flowDelegate?.navigate(step: .confirmTappedFromLocalizationConfirmation(country: selectedCountry))
    }
}
