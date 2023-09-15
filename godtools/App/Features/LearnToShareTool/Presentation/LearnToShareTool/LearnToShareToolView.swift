//
//  LearnToShareToolView.swift
//  godtools
//
//  Created by Levi Eggert on 8/7/23.
//  Copyright © 2020 Cru. All rights reserved.
//

import SwiftUI

struct LearnToShareToolView: View {
    
    private let pageControlAttributes: PageControlAttributesType = GTPageControlAttributes()
    private let continueButtonPadding: CGFloat = 50
    
    @ObservedObject private var viewModel: LearnToShareToolViewModel
    
    init(viewModel: LearnToShareToolViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(spacing: 0) {
                
                PagedView(numberOfPages: viewModel.numberOfLearnToShareToolItems, currentPage: $viewModel.currentPage) { page in
                    
                    LearnToShareToolItemView(
                        viewModel: viewModel.getLearnToShareToolItemViewModel(index: page),
                        geometry: geometry
                    )
                }
                
                GTBlueButton(title: viewModel.continueTitle, font: FontLibrary.sfProTextRegular.font(size: 18), width: geometry.size.width - (continueButtonPadding * 2), height: 50) {
                    
                    viewModel.continueTapped()
                }
                            
                PageControl(
                    numberOfPages: viewModel.numberOfLearnToShareToolItems,
                    attributes: pageControlAttributes,
                    currentPage: $viewModel.currentPage
                )
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 10, trailing: 0))
            }
        }
    }
}
