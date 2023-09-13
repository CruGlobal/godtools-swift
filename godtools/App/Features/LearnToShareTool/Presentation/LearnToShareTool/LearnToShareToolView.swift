//
//  LearnToShareToolView.swift
//  godtools
//
//  Created by Levi Eggert on 8/7/23.
//  Copyright © 2020 Cru. All rights reserved.
//

import SwiftUI

struct LearnToShareToolView: View {
    
    private let layoutDirection: LayoutDirection = .leftToRight
    private let pageControlAttributes: PageControlAttributesType = GTPageControlAttributes()
    private let continueButtonPadding: CGFloat = 50
    
    @ObservedObject private var viewModel: LearnToShareToolViewModel
    
    init(viewModel: LearnToShareToolViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(spacing: 0) {
                
                TabView(selection: $viewModel.currentPage) {
                    
                    Group {
                        
                        ForEach(0 ..< viewModel.numberOfLearnToShareToolItems, id: \.self) { index in
                            
                            LearnToShareToolItemView(
                                viewModel: viewModel.getLearnToShareToolItemViewModel(index: index),
                                geometry: geometry
                            )
                            .tag(index)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeOut, value: viewModel.currentPage)
                
                GTBlueButton(title: viewModel.continueTitle, font: FontLibrary.sfProTextRegular.font(size: 18), width: geometry.size.width - (continueButtonPadding * 2), height: 50) {
                    
                    viewModel.continueTapped()
                }
                            
                PageControl(
                    layoutDirection: layoutDirection,
                    numberOfPages: viewModel.numberOfLearnToShareToolItems,
                    attributes: pageControlAttributes,
                    currentPage: $viewModel.currentPage
                )
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 10, trailing: 0))
            }
        }
        .flipsForRightToLeftLayoutDirection(true)
    }
}
