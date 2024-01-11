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

enum NavBarItemControllerType {
     
    case appInterfaceString(getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase)
    case appLayoutDirection(layoutDirectionPublisher: AnyPublisher<UISemanticContentAttribute, Never>?)
    case base
}
