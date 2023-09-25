//
//  ChangeUIDirectionFromLocale.swift
//  godtools
//
//  Created by Gyasi Story on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    
    func changeUIDirectionFromLanguage() -> some View {
        let language = Locale.current.languageCode
        let direction = Locale.characterDirection(forLanguage: language ?? "en")
        var uiDirection: SwiftUI.LayoutDirection = SwiftUI.LayoutDirection.leftToRight
        switch direction {
            case .leftToRight:
                uiDirection = SwiftUI.LayoutDirection.leftToRight
            case .rightToLeft:
                uiDirection = SwiftUI.LayoutDirection.rightToLeft
            default:
                uiDirection = SwiftUI.LayoutDirection.leftToRight
        }
        return self.environment(\.layoutDirection, uiDirection)
    }
}
