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
    private let continueButtonHeight: CGFloat = 50
    
    @ObservedObject private var viewModel: ToolScreenShareTutorialViewModel
    
    init(viewModel: ToolScreenShareTutorialViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(alignment: .center, spacing: 0) {
                
                FixedVerticalSpacer(height: 50)
                
                if viewModel.tutorialPages.count > 0 {
                    
                    TabView(selection: $viewModel.currentPage) {
                        
                        Group {
                            
                            if ApplicationLayout.shared.layoutDirection == .rightToLeft {
                                
                                ForEach((0 ..< viewModel.tutorialPages.count).reversed(), id: \.self) { index in
                                    
                                    getToolScreenShareTutorialPage(index: index, geometry: geometry)
                                        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
                                        .tag(index)
                                }
                            }
                            else {
                                
                                ForEach(0 ..< viewModel.tutorialPages.count, id: \.self) { index in
                                    
                                    getToolScreenShareTutorialPage(index: index, geometry: geometry)
                                        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
                                        .tag(index)
                                }
                            }
                        }
                    }
                    .environment(\.layoutDirection, .leftToRight)
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeOut, value: viewModel.currentPage)
                }
                
                HStack(alignment: .center, spacing: 12) {
                    
                    let isSingleButton: Bool = viewModel.hidesGenerateQRCodeButton
                    
                    let horizontalPadding: CGFloat = isSingleButton ? 50 : 30
                    
                    let titlePadding: CGFloat? = isSingleButton ? nil : 4
                    
                    let buttonWidth: CGFloat = isSingleButton
                    ? (geometry.size.width - (horizontalPadding * 2))
                    : floor(geometry.size.width / 2) - horizontalPadding
                    
                    let buttonFontSize: CGFloat = isSingleButton ? 18 : 16
                    
                    let buttonFont: Font = FontLibrary.sfProTextRegular.font(size: buttonFontSize)
                    
                    if !viewModel.hidesGenerateQRCodeButton {
                        
                        GTWhiteButton(
                            title: viewModel.generateQRCodeButtonTitle,
                            font: buttonFont,
                            width: buttonWidth,
                            height: continueButtonHeight,
                            titleHorizontalPadding: titlePadding,
                            titleVerticalPadding: titlePadding
                        ) {
                            
                            viewModel.generateQRCodeTapped()
                        }
                    }
                    
                    GTBlueButton(
                        title: viewModel.continueTitle,
                        font: buttonFont,
                        width: buttonWidth,
                        height: continueButtonHeight,
                        titleHorizontalPadding: titlePadding,
                        titleVerticalPadding: titlePadding
                    ) {
                        
                        viewModel.continueTapped()
                    }
                }
                
                if viewModel.tutorialPages.count > 0 {
                    
                    PageControl(
                        numberOfPages: viewModel.tutorialPages.count,
                        attributes: pageControlAttributes,
                        currentPage: $viewModel.currentPage
                    )
                    .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
    
    private func getToolScreenShareTutorialPage(index: Int, geometry: GeometryProxy) -> ToolScreenShareTutorialPageView {
        
        return ToolScreenShareTutorialPageView(
            tutorialPage: viewModel.tutorialPages[index],
            geometry: geometry
        )
    }
}
