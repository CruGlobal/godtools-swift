//
//  CircleSelectorView.swift
//  godtools
//
//  Created by Levi Eggert on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct CircleSelectorView: View {
        
    @Binding var isSelected: Bool
    
    var body: some View {
        
        ZStack {
            Image(ImageCatalog.circleSelectorBackground.name)
                .frame(width: 20, height: 20, alignment: .leading)
            Circle()
                .fill(isSelected ? ColorPalette.gtBlue.color : .clear)
                .frame(width: 16, height: 16, alignment: .leading)
        }
    }
}
