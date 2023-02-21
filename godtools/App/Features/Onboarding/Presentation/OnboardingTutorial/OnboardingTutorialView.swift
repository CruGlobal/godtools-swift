//
//  OnboardingTutorialView.swift
//  godtools
//
//  Created by Levi Eggert on 2/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct OnboardingTutorialView: View {
        
    @ObservedObject var viewModel: OnboardingTutorialViewModel
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(alignment: .leading, spacing: 0) {
                
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
                                    viewModel: viewModel.getOnboardingTutorialTalkAboutGodWithAnyoneViewModel()
                                )
                                
                            case .prepareForTheMomentsThatMatter:
                                
                                OnboardingTutorialMediaView(
                                    viewModel: viewModel.getOnboardingTutorialPrepareForTheMomentsThatMatterViewModel()
                                )
                                
                            case .helpSomeoneDiscoverJesus:
                                
                                OnboardingTutorialMediaView(
                                    viewModel: viewModel.getOnboardingTutorialHelpSomeoneDiscoverJesusViewModel()
                                )
                            }
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeOut, value: viewModel.currentPage)
                
                GTBlueButton(title: viewModel.continueButtonTitle, fontSize: 15, height: 50) {
                    
                    viewModel.continueTapped()
                }
                .padding(EdgeInsets(top: 0, leading: 30, bottom: 30, trailing: 30))
                
                GTPageControl(numberOfPages: 4, currentPage: $viewModel.currentPage)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0))
            }
            .frame(maxWidth: .infinity)
        }
    }
}
