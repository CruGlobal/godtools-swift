//
//  NavBarItemControllerType.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import UIKit
import Combine
import LocalizationServices

enum NavBarItemControllerType {
     
    case appInterfaceString(getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, localizationServices: LocalizationServicesInterface)
    case appLayoutDirection(layoutDirectionPublisher: AnyPublisher<UISemanticContentAttribute, Never>?)
    case base
}
