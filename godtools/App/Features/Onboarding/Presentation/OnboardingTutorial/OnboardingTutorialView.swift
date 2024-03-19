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
                   
                TabView(selection: $viewModel.currentPage) {
                    
                    Group {
                        
                        if ApplicationLayout.shared.layoutDirection == .rightToLeft {
                            
                            ForEach((0 ..< viewModel.pages.count).reversed(), id: \.self) { index in
                                
                                getOnboardingTutorialView(index: index, geometry: geometry)
                                    .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
                                    .tag(index)
                            }
                        }
                        else {
                            
                            ForEach(0 ..< viewModel.pages.count, id: \.self) { index in
                                
                                getOnboardingTutorialView(index: index, geometry: geometry)
                                    .environment(\.layoutDirection, ApplicationLayout.shared.layoutDirection)
                                    .tag(index)
                            }
                        }
                    }
                }
                .environment(\.layoutDirection, .leftToRight)
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeOut, value: viewModel.currentPage)
                
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
    
    @ViewBuilder private func getOnboardingTutorialView(index: Int, geometry: GeometryProxy) -> some View {
        
        switch viewModel.pages[index] {
            
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
}

extension OnboardingTutorialView {
    
    func getCurrentPage() -> Int {
        return viewModel.currentPage
    }
    
    func setCurrentPage(page: Int) {
        viewModel.currentPage = page
    }
}
