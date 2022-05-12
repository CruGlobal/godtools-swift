//
//  View+ConditionalViewBuilder.swift
//  godtools
//
//  Created by Levi Eggert on 5/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

extension View {
    func condition<Content>(@ViewBuilder _ transform: (Self) -> Content) -> Content {
        transform(self)
    }
}

