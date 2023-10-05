//
//  AppInterfaceStringBarItem.swift
//  godtools
//
//  Created by Levi Eggert on 10/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import Combine

class AppInterfaceStringBarItem: NavBarItem {
    
    let localizedStringKey: String
    
    init(getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase, localizedStringKey: String, style: UIBarButtonItem.Style?, color: UIColor?, target: AnyObject, action: Selector, toggleVisibilityPublisher: AnyPublisher<Bool, Never>? = nil) {
        
        self.localizedStringKey = localizedStringKey
        
        super.init(
            controllerType: .appInterfaceString(getInterfaceStringInAppLanguageUseCase: getInterfaceStringInAppLanguageUseCase),
            itemData: NavBarItemData(
                contentType: .title(value: ""),
                style: style,
                color: color,
                target: target,
                action: action
            ),
            toggleVisibilityPublisher: toggleVisibilityPublisher
        )
    }
}
