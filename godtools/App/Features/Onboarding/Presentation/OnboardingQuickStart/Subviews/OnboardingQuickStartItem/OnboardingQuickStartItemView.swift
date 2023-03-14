//
//  OnboardingQuickStartItemView.swift
//  godtools
//
//  Created by Levi Eggert on 3/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct OnboardingQuickStartItemView: View {
    
    private let backgroundColor: Color = ColorPalette.getColorWithRGB(red: 244, green: 244, blue: 244, opacity: 1)
    
    @ObservedObject var viewModel: OnboardingQuickStartItemViewModel
    
    let geometry: GeometryProxy
    let itemTappedClosure: (() -> Void)
    
    var body: some View {
        
        ZStack(alignment: .leading) {
                            
            VStack(alignment: .leading, spacing: 0) {
                
                Text(viewModel.title)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .font(Font.system(size: 18, weight: .regular))
                                
                HStack(alignment: .center, spacing: 8) {
                    
                    Text(viewModel.actionTitle)
                        .foregroundColor(ColorPalette.gtBlue.color)
                    
                    ImageCatalog.rightArrowBlue.image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height:12)
                        .clipped()
                }
                .padding(EdgeInsets(top: 3, leading: 0, bottom: 0, trailing: 0) )
            }
            .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .onTapGesture {
            itemTappedClosure()
        }
    }
}
