//
//  OnboardingQuickStartView.swift
//  godtools
//
//  Created by Levi Eggert on 3/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct OnboardingQuickStartView: View {
    
    private let itemTopPadding: CGFloat = 10
    private let itemSpacing: CGFloat = 10
    private let itemHorizontalPadding: CGFloat = 30
    
    @ObservedObject var viewModel: OnboardingQuickStartViewModel
    
    var body: some View {
         
        GeometryReader { geometry in
            
            VStack(alignment: .center, spacing: 0) {
                
                Text(viewModel.title)
                    .multilineTextAlignment(.center)
                    .foregroundColor(ColorPalette.gtBlue.color)
                    .font(Font.system(size: 26, weight: .light))
                    .padding(EdgeInsets(top: 30, leading: 30, bottom: 15, trailing: 30))
                
                ScrollView(.vertical, showsIndicators: true) {
                    
                    LazyVStack(alignment: .center, spacing: itemSpacing) {
                        
                        ForEach(0 ..< viewModel.numberOfQuickStartItems, id: \.self) { index in
                            
                            OnboardingQuickStartItemView(
                                viewModel: viewModel.getQuickStartItemViewModel(index: index),
                                geometry: geometry,
                                itemTappedClosure: {
                                    viewModel.quickStartItemTapped(index: index)
                                })
                            .padding(EdgeInsets(top: 0, leading: itemHorizontalPadding, bottom: 0, trailing: itemHorizontalPadding))
                        }
                    }
                    .padding(EdgeInsets(top: itemTopPadding, leading: 0, bottom: 0, trailing: 0))
                }
                
                Spacer()
                
                OnboardingTutorialPrimaryButton(geometry: geometry, title: viewModel.endTutorialButtonTitle) {
                    viewModel.endTutorialTapped()
                }
                
                FixedVerticalSpacer(height: 30)
            }
        }
    }
}
