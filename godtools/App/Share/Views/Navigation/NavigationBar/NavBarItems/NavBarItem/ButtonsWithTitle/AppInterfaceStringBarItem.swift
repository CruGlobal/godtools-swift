//
//  AppInterfaceStringBarItem.swift
//  godtools
//
//  Created by Levi Eggert on 10/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import Combine
import LocalizationServices

class AppInterfaceStringBarItem: NavBarItem {
    
    let localizedStringKey: String
    
    init(getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, localizationServices: LocalizationServicesInterface, localizedStringKey: String, color: UIColor?, target: AnyObject, action: Selector, accessibilityIdentifier: String?, hidesBarItemPublisher: AnyPublisher<Bool, Never>? = nil) {
        
        self.localizedStringKey = localizedStringKey
        
        super.init(
            controllerType: .appInterfaceString(getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase, localizationServices: localizationServices),
            itemData: NavBarItemData(
                contentType: .title(value: ""),
                color: color,
                target: target,
                action: action,
                accessibilityIdentifier: accessibilityIdentifier
            ),
            hidesBarItemPublisher: hidesBarItemPublisher
        )
    }
}
