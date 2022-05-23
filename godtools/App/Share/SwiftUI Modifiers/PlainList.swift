//
//  PlainList.swift
//  godtools
//
//  Created by Rachael Skeath on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct PlainList: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .edgesIgnoringSafeArea([.leading, .trailing])
            .listStyle(.plain)
    }
}
