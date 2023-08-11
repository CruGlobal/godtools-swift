//
//  OnboardingTutorialView.swift
//  godtools
//
//  Created by Levi Eggert on 2/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct OnboardingTutorialView: View {
        
    @ObservedObject private var viewModel: OnboardingTutorialViewModel
    
    init(viewModel: OnboardingTutorialViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(alignment: .center, spacing: 0) {
                                
                TabView(selection: $viewModel.currentPage) {

                    Group {
                        
                        ForEach((0 ..< viewModel.pages.count), id: \.self) { index in
                            
                            switch viewModel.pages[index] {
                                
                            case .readyForEveryConversation:
                               
                                OnboardingTutorialReadyForEveryConversationView(
                                    viewModel: viewModel.getOnboardingTutorialReadyForEveryConversationViewModel(),
                                    geometry: geometry,
                                    watchVideoTappedClosure: {
                                        viewModel.watchReadyForEveryConversationVideoTapped()
                                    }
                                )
                                
                            case .talkAboutGodWithAnyone:
                                
                                OnboardingTutorialMediaView(
                                    viewModel: viewModel.getOnboardingTutorialTalkAboutGodWithAnyoneViewModel(),
                                    geometry: geometry
                                )
                                
                            case .prepareForTheMomentsThatMatter:
                                
                                OnboardingTutorialMediaView(
                                    viewModel: viewModel.getOnboardingTutorialPrepareForTheMomentsThatMatterViewModel(),
                                    geometry: geometry
                                )
                                
                            case .helpSomeoneDiscoverJesus:
                                
                                OnboardingTutorialMediaView(
                                    viewModel: viewModel.getOnboardingTutorialHelpSomeoneDiscoverJesusViewModel(),
                                    geometry: geometry
                                )
                            }
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeOut, value: viewModel.currentPage)
                     
                OnboardingTutorialPrimaryButton(geometry: geometry, title: viewModel.continueButtonTitle) {
                    viewModel.continueTapped()
                }
                
                FixedVerticalSpacer(height: 30)
                
                PageControl(numberOfPages: 4, attributes: GTPageControlAttributes(), currentPage: $viewModel.currentPage)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
            }
            .frame(maxWidth: .infinity)
        }
    }
}
