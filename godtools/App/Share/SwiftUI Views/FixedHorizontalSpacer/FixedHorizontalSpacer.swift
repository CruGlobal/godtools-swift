//
//  FixedHorizontalSpacer.swift
//  godtools
//
//  Created by Levi Eggert on 11/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct FixedHorizontalSpacer: View {
   
    let width: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: width)
    }
}
