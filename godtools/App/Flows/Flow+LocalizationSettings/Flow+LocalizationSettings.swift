//
//  Flow+LocalizationSettings.swift
//  godtools
//
//  Created by Levi Eggert on 2/4/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import UIKit

extension Flow {
    
    func getLocalizationSettingsView(showsPreferNotToSay: Bool) -> UIViewController {

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
}
