//
//  AppSkipBarItem.swift
//  godtools
//
//  Created by Levi Eggert on 10/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class AppSkipBarItem: AppInterfaceStringBarItem {
    
    init(getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, target: AnyObject, action: Selector, toggleVisibilityPublisher: AnyPublisher<Bool, Never>? = nil) {
        
        super.init(
            getInterfaceStringInAppLanguageUseCase: getInterfaceStringInAppLanguageUseCase,
            localizedStringKey: "navigationBar.navigationItem.skip",
            style: .plain,
            color: ColorPalette.gtBlue.uiColor,
            target: target,
            action: action,
            toggleVisibilityPublisher: toggleVisibilityPublisher
        )
    }
}
