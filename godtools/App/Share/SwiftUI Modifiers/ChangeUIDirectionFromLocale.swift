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
                let uiDirection = switch direction {
                case .leftToRight:
                    SwiftUI.LayoutDirection.leftToRight
                case .rightToLeft:
                    SwiftUI.LayoutDirection.rightToLeft
                @unknown default:
                    SwiftUI.LayoutDirection.leftToRight
                }
        return self.environment(\.layoutDirection, uiDirection)
    }
}
