//
//  LocalizationSettingsFlow.swift
//  godtools
//
//  Created by Levi Eggert on 3/4/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import UIKit
import Combine

final class LocalizationSettingsFlow: Flow {
            
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    
    private let shouldStoreCountryWhenSelected: Bool
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: AppNavigationController, showsPreferNotToSay: Bool, shouldStoreCountryWhenSelected: Bool, animated: Bool = true) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.shouldStoreCountryWhenSelected = shouldStoreCountryWhenSelected
        
        let localizationSettings = getLocalizationSettingsView(showsPreferNotToSay: showsPreferNotToSay)
        
        sharedNavigationController.pushViewController(localizationSettings, animated: animated)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .backTappedFromLocalizationSettings:
            flowDelegate?.navigate(step: .localizationSettingsFlowCompleted(state: .userTappedBackFromLocalizationSettings))
            
        case .countryTappedFromLocalizationSettings(let countryListItem):
            storeSelectedCountryListItem(countryListItem: countryListItem)
            
        case .closeTappedFromLocalizationConfirmation:
            break
            
        case .cancelTappedFromLocalizationConfirmation:
            break
            
        case .confirmTappedFromLocalizationConfirmation(let countryListItem):
            break
            
        default:
            break
        }
    }
    
    private func storeSelectedCountryListItem(countryListItem: LocalizationSettingsCountryListItem) {
        
        guard shouldStoreCountryWhenSelected else {
            return
        }
        
        appDiContainer
            .feature
            .personalizedTools
            .domainLayer
            .getSetLocalizationSettingsUseCase()
            .execute(country: countryListItem.countryDomainModel)
            .sink { _ in

            } receiveValue: { _ in

            }
            .store(in: &Self.backgroundCancellables)
    }
}

extension LocalizationSettingsFlow {
    
    private func getLocalizationSettingsView(showsPreferNotToSay: Bool) -> UIViewController {

        let viewModel = LocalizationSettingsViewModel(
            flowDelegate: self,
            showsPreferNotToSay: showsPreferNotToSay,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getCountryListUseCase: appDiContainer.feature.personalizedTools.domainLayer.getLocalizationSettingsCountryListUseCase(),
            getLocalizationSettingsUseCase: appDiContainer.feature.personalizedTools.domainLayer.getGetLocalizationSettingsUseCase(),
            searchCountriesUseCase: appDiContainer.feature.personalizedTools.domainLayer.getSearchCountriesInLocalizationSettingsCountriesListUseCase(),
            viewLocalizationSettingsUseCase: appDiContainer.feature.personalizedTools.domainLayer.getViewLocalizationSettingsUseCase(),
            viewSearchBarUseCase: appDiContainer.domainLayer.getViewSearchBarUseCase()
        )
        
        let view = LocalizationSettingsView(viewModel: viewModel)
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped),
            accessibilityIdentifier: nil
        )
        
        let hostingView = AppHostingController<LocalizationSettingsView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: backButton,
                leadingItems: [],
                trailingItems: []
            )
        )
        
        return hostingView
    }
    
    private func getLocalizationSettingsConfirmationView(selectedCountry: LocalizationSettingsCountryListItem) -> UIViewController {

        let confirmationViewModel = LocalizationSettingsConfirmationViewModel(
            flowDelegate: self,
            selectedCountry: selectedCountry,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getLocalizationSettingsConfirmationStringsUseCase: appDiContainer.feature.personalizedTools.domainLayer.getLocalizationSettingsConfirmationStringsUseCase()
        )

        let confirmationView = LocalizationSettingsConfirmationView(viewModel: confirmationViewModel)

        let hostingView = AppHostingController<LocalizationSettingsConfirmationView>(
            rootView: confirmationView,
            navigationBar: nil
        )

        hostingView.modalPresentationStyle = .overFullScreen
        hostingView.modalTransitionStyle = .crossDissolve
        hostingView.view.backgroundColor = .clear

        return hostingView
    }
}
