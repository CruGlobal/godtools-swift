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
            
            AccessibilityScreenElementView(screenAccessibility: .toolScreenShareTutorial)
            
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
                
                let buttonHorizontalPadding: CGFloat = 30
                let singleButtonWidth: CGFloat = geometry.size.width - (buttonHorizontalPadding * 2)
                
                if viewModel.shareOptions.count > 0 {
                    
                    let isSingleButton: Bool = viewModel.shareOptions.count == 1
                    let buttonFontSize: CGFloat = 16
                    let buttonFont: Font = FontLibrary.sfProTextRegular.font(size: buttonFontSize)
                    let numberOfButtons: CGFloat = CGFloat(viewModel.shareOptions.count)
                    let buttonWidth: CGFloat = isSingleButton ? singleButtonWidth : floor(geometry.size.width / numberOfButtons) - buttonHorizontalPadding
                    let titlePadding: CGFloat = 4
                    
                    HStack(alignment: .center, spacing: 12) {
                        
                        if viewModel.shareOptions.contains(.qrCode) {
                            
                            GTWhiteButton(
                                title: viewModel.generateQRCodeButtonTitle,
                                font: buttonFont,
                                width: buttonWidth,
                                height: continueButtonHeight,
                                titleHorizontalPadding: titlePadding,
                                titleVerticalPadding: titlePadding,
                                accessibility: .generateQRCode
                            ) {
                                
                                viewModel.generateQRCodeTapped()
                            }
                        }
                        
                        if viewModel.shareOptions.contains(.shareLink) {
                            
                            GTBlueButton(
                                title: viewModel.shareLinkButtonTitle,
                                font: buttonFont,
                                width: buttonWidth,
                                height: continueButtonHeight,
                                titleHorizontalPadding: titlePadding,
                                titleVerticalPadding: titlePadding,
                                accessibility: .shareLink
                            ) {
                                
                                viewModel.shareLinkTapped()
                            }
                        }
                    }
                }
                
                if !viewModel.hidesContinueButton {
                    
                    GTBlueButton(
                        title: viewModel.continueTitle,
                        font: FontLibrary.sfProTextRegular.font(size: 18),
                        width: singleButtonWidth,
                        height: continueButtonHeight,
                        titleHorizontalPadding: nil,
                        titleVerticalPadding: nil,
                        accessibility: .continueForward
                    ) {
                        
                        viewModel.continueTapped()
                    }
                }
                
                if viewModel.tutorialPages.count > 1 {
                    
                    PageControl(
                        numberOfPages: viewModel.tutorialPages.count,
                        attributes: pageControlAttributes,
                        currentPage: $viewModel.currentPage
                    )
                    .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                }
            }
            .frame(maxWidth: .infinity)
            .padding([.bottom], 20)
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
