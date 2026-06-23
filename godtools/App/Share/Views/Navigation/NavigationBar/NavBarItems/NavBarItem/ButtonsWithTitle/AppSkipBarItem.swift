//
//  AppSkipBarItem.swift
//  godtools
//
//  Created by Levi Eggert on 10/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
class AppSkipBarItem: AppInterfaceStringBarItem {
    
    init(
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        localizationServices: LocalizationServicesInterface,
        target: AnyObject,
        action: Selector,
        accessibilityIdentifier: String?,
        hidesBarItemPublisher: AnyPublisher<Bool, Never>? = nil
    ) {
        
        super.init(
            getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase,
            localizationServices: localizationServices,
            localizedStringKey: "navigationBar.navigationItem.skip",
            color: ColorPalette.gtBlue.uiColor,
            target: target,
            action: action,
            accessibilityIdentifier: accessibilityIdentifier,
            hidesBarItemPublisher: hidesBarItemPublisher
        )
    }
}
