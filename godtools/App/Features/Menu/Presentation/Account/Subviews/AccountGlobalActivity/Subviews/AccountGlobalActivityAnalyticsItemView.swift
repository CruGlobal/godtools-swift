//
//  AccountGlobalActivityAnalyticsItemView.swift
//  godtools
//
//  Created by Levi Eggert on 11/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct AccountGlobalActivityAnalyticsItemView: View {
    
    private let cornerRadius: CGFloat = 10
    
    @ObservedObject private var viewModel: AccountGlobalActivityAnalyticsItemViewModel
    
    init(viewModel: AccountGlobalActivityAnalyticsItemViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            Color.white
                .cornerRadius(cornerRadius)
                .shadow(
                    color: Color.black.opacity(0.3),
                    radius: 4,
                    x: 1,
                    y: 1
                )
            
            VStack(alignment: .center, spacing: 0) {
                
                Text(viewModel.count)
                    .font(FontLibrary.sfProTextSemibold.font(size: 25))
                    .foregroundColor(Color.getColorWithRGB(red: 151, green: 151, blue: 151, opacity: 1))
                    .multilineTextAlignment(.center)
                
                Text(viewModel.label)
                    .font(FontLibrary.sfProTextLight.font(size: 12))
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
