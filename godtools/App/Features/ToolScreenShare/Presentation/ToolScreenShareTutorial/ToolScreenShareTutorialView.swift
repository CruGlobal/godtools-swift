//
//  ToolScreenShareTutorialView.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ToolScreenShareTutorialView: View {
    
    private let pageControlAttributes: PageControlAttributesType = GTPageControlAttributes()
    private let continueButtonHorizontalPadding: CGFloat = 50
    private let continueButtonHeight: CGFloat = 50
    
    @ObservedObject private var viewModel: ToolScreenShareTutorialViewModel
    
    init(viewModel: ToolScreenShareTutorialViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(alignment: .center, spacing: 0) {
                
                FixedVerticalSpacer(height: 50)
                
                PagedView(numberOfPages: viewModel.tutorialPages.count, currentPage: $viewModel.currentPage) { (index: Int) in
                    
                    ToolScreenShareTutorialPageView(
                        tutorialPage: viewModel.tutorialPages[index],
                        geometry: geometry
                    )
                }
                
                GTBlueButton(title: viewModel.continueTitle, font: FontLibrary.sfProTextRegular.font(size: 18), width: geometry.size.width - (continueButtonHorizontalPadding * 2), height: continueButtonHeight) {
                    
                    viewModel.continueTapped()
                }
                
                PageControl(
                    numberOfPages: viewModel.tutorialPages.count,
                    attributes: pageControlAttributes,
                    currentPage: $viewModel.currentPage
                )
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
            }
            .frame(maxWidth: .infinity)
        }
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
}
