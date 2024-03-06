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
    
    private func getToolScreenShareTutorialPage(index: Int, geometry: GeometryProxy) -> ToolScreenShareTutorialPageView {
        
        return ToolScreenShareTutorialPageView(
            tutorialPage: viewModel.tutorialPages[index],
            geometry: geometry
        )
    }
}
