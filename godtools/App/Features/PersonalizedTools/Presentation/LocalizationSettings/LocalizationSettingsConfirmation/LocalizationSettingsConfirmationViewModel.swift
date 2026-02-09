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
    private var cancellables: Set<AnyCancellable> = Set()

    private weak var flowDelegate: FlowDelegate?

    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.rawValue
    @Published private(set) var strings = LocalizationSettingsConfirmationStringsDomainModel.emptyValue

    let selectedCountry: LocalizationSettingsCountryListItemDomainModel

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
            .flatMap { [weak self] appLanguage in
                guard let self = self else {
                    return Just(LocalizationSettingsConfirmationStringsDomainModel.emptyValue).eraseToAnyPublisher()
                }
                return self.getLocalizationSettingsConfirmationStringsUseCase.execute(appLanguage: appLanguage, selectedCountry: self.selectedCountry)
            }
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
        flowDelegate?.navigate(step: .closeLocalizationConfirmationFromLocalizationSettings)
    }

    func cancelTapped() {
        flowDelegate?.navigate(step: .cancelLocalizationConfirmationFromLocalizationSettings)
    }

    func confirmTapped() {
        flowDelegate?.navigate(step: .confirmLocalizationConfirmationFromLocalizationSettings(country: selectedCountry))
    }
}
