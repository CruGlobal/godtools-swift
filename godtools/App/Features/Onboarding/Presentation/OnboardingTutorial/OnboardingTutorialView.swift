//
//  OnboardingTutorialView.swift
//  godtools
//
//  Created by Levi Eggert on 2/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct OnboardingTutorialView: View {
        
    private static let chooseAppLanguageButtonHiddenPosition: CGFloat = (ChooseAppLanguageButton.height * 3) * -1
    private static let chooseAppLanguageButtonVisiblePosition: CGFloat = -40
    
    @State private var chooseAppLanguageButtonPosition: CGFloat = OnboardingTutorialView.chooseAppLanguageButtonHiddenPosition
    
    @ObservedObject private var viewModel: OnboardingTutorialViewModel
    
    init(viewModel: OnboardingTutorialViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            AccessibilityScreenElementView(screenAccessibility: .onboardingTutorial)

            VStack(alignment: .center, spacing: 0) {
                   
                PagedView(numberOfPages: viewModel.pages.count, currentPage: $viewModel.currentPage) { (page: Int) in
                    
                    switch viewModel.pages[page] {
                        
                    case .readyForEveryConversation:
                       
                        OnboardingTutorialReadyForEveryConversationView(
                            viewModel: viewModel.getOnboardingTutorialReadyForEveryConversationViewModel(),
                            geometry: geometry,
                            screenAccessibility: .onboardingTutorialPage1,
                            watchVideoTappedClosure: {
                                viewModel.watchReadyForEveryConversationVideoTapped()
                            }
                        )
                        
                    case .talkAboutGodWithAnyone:
                        
                        OnboardingTutorialMediaView(
                            viewModel: viewModel.getOnboardingTutorialTalkAboutGodWithAnyoneViewModel(),
                            geometry: geometry,
                            screenAccessibility: .onboardingTutorialPage2
                        )
                        
                    case .prepareForTheMomentsThatMatter:
                        
                        OnboardingTutorialMediaView(
                            viewModel: viewModel.getOnboardingTutorialPrepareForTheMomentsThatMatterViewModel(),
                            geometry: geometry,
                            screenAccessibility: .onboardingTutorialPage3
                        )
                        
                    case .helpSomeoneDiscoverJesus:
                        
                        OnboardingTutorialMediaView(
                            viewModel: viewModel.getOnboardingTutorialHelpSomeoneDiscoverJesusViewModel(),
                            geometry: geometry,
                            screenAccessibility: .onboardingTutorialPage4
                        )
                    }
                }
                
                OnboardingTutorialPrimaryButton(geometry: geometry, title: viewModel.continueButtonTitle, accessibility: .nextOnboardingTutorial) {
                    viewModel.continueTapped()
                }
                
                FixedVerticalSpacer(height: 30)
                
                PageControl(numberOfPages: 4, attributes: GTPageControlAttributes(), currentPage: $viewModel.currentPage)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
            }
            .frame(maxWidth: .infinity)
            
            let chooseAppLanguageButtonPosition: CGFloat = viewModel.showsChooseLanguageButton ? OnboardingTutorialView.chooseAppLanguageButtonVisiblePosition : OnboardingTutorialView.chooseAppLanguageButtonHiddenPosition
            
            ChooseAppLanguageCenteredHorizontallyView(buttonTitle: viewModel.chooseAppLanguageButtonTitle) {
                viewModel.chooseAppLanguageTapped()
            }
            .padding([.top], chooseAppLanguageButtonPosition)
            .animation(.interpolatingSpring(stiffness: 80, damping: 10), value: chooseAppLanguageButtonPosition)
        }
        .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
    }
}

extension OnboardingTutorialView {
    
    func getCurrentPage() -> Int {
        return viewModel.currentPage
    }
    
    func setCurrentPage(page: Int) {
        viewModel.currentPage = page
    }
}
