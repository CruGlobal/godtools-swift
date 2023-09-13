//
//  TutorialView.swift
//  godtools
//
//  Created by Levi Eggert on 8/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct TutorialView: View {
    
    private let layoutDirection: LayoutDirection = .leftToRight
    private let pageControlAttributes: PageControlAttributesType = GTPageControlAttributes()
    private let continueButtonHorizontalPadding: CGFloat = 50
    private let continueButtonHeight: CGFloat = 50
    
    @ObservedObject private var viewModel: TutorialViewModel
    
    init(viewModel: TutorialViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(alignment: .center, spacing: 0) {
                
                FixedVerticalSpacer(height: 50)
                
                PagedView(layoutDirection: layoutDirection, numberOfPages: viewModel.numberOfPages, currentPage: $viewModel.currentPage) { page in
                    
                    TutorialItemView(
                        viewModel: viewModel.tutorialPageWillAppear(tutorialItemIndex: page),
                        geometry: geometry,
                        videoPlayingClosure: {
                            viewModel.tutorialVideoPlayTapped(tutorialItemIndex: page)
                        }
                    )
                }
                
                /*
                TabView(selection: $viewModel.currentPage) {
                    
                    Group {
                        
                        ForEach(0 ..< viewModel.numberOfPages, id: \.self) { index in
                            
                            TutorialItemView(
                                viewModel: viewModel.tutorialPageWillAppear(tutorialItemIndex: index),
                                geometry: geometry,
                                videoPlayingClosure: {
                                    viewModel.tutorialVideoPlayTapped(tutorialItemIndex: index)
                                }
                            )
                            .tag(index)
                            
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeOut, value: viewModel.currentPage)
                */
                
                GTBlueButton(title: viewModel.continueTitle, font: FontLibrary.sfProTextRegular.font(size: 18), width: geometry.size.width - (continueButtonHorizontalPadding * 2), height: continueButtonHeight) {
                    
                    viewModel.continueTapped()
                }
                
                PageControl(
                    layoutDirection: layoutDirection,
                    numberOfPages: viewModel.numberOfPages,
                    attributes: pageControlAttributes,
                    currentPage: $viewModel.currentPage
                )
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
            }
            .frame(maxWidth: .infinity)
        }
    }
}
