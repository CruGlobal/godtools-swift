//
//  OptionalVerticalPadding.swift
//  godtools
//
//  Created by Levi Eggert on 6/18/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder
    func optionalVerticalPoadding(_ value: CGFloat?) -> some View {
        if let value = value {
            padding([.vertical], value)
        } else {
            self
        }
    }
}
