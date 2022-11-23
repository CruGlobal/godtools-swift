//
//  FixedVerticalSpacer.swift
//  godtools
//
//  Created by Levi Eggert on 11/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct FixedVerticalSpacer: View {
   
    let height: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: height)
    }
}
