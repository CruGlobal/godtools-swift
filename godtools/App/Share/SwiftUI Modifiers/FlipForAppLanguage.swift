//
//  FlipForAppLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct FlipForAppLanguage: ViewModifier {

    func body(content: Content) -> some View {

        content
            .environment(\.layoutDirection, ApplicationLayout.direction.layoutDirection)
    }
}
