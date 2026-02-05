//
//  OnboardingTutorialView.swift
//  godtools
//
//  Created by Levi Eggert on 2/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct OnboardingTutorialView: View {
        
    private static let navAreaHeight: CGFloat = 120
    private static let chooseAppLanguageButtonHiddenPosition: CGFloat = (navAreaHeight + ChooseAppLanguageButton.height) * -1
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
                   
                if viewModel.pages.count > 0 {
                 
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
                }
                
                OnboardingTutorialPrimaryButton(geometry: geometry, title: viewModel.continueButtonTitle, accessibility: viewModel.continueButtonAccessibility) {
                    viewModel.continueTapped()
                }
                
                FixedVerticalSpacer(height: 30)
                
                if viewModel.pages.count > 0 {
                    
                    PageControl(numberOfPages: 4, attributes: GTPageControlAttributes(), currentPage: $viewModel.currentPage)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                }
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
        
        let screenAccessibilityId = AccessibilityStrings.Screen.getPageAccessibility(screen: .onboardingTutorialPage, page: index)
        
        switch viewModel.pages[index] {
            
        case .readyForEveryConversation:
           
            OnboardingTutorialReadyForEveryConversationView(
                viewModel: viewModel.getOnboardingTutorialReadyForEveryConversationViewModel(),
                geometry: geometry,
                screenAccessibilityId: screenAccessibilityId,
                watchVideoTappedClosure: {
                    viewModel.watchReadyForEveryConversationVideoTapped()
                }
            )
            
        case .talkAboutGodWithAnyone:
            
            OnboardingTutorialMediaView(
                viewModel: viewModel.getOnboardingTutorialTalkAboutGodWithAnyoneViewModel(),
                geometry: geometry,
                screenAccessibilityId: screenAccessibilityId
            )
            
        case .prepareForTheMomentsThatMatter:
            
            OnboardingTutorialMediaView(
                viewModel: viewModel.getOnboardingTutorialPrepareForTheMomentsThatMatterViewModel(),
                geometry: geometry,
                screenAccessibilityId: screenAccessibilityId
            )
            
        case .helpSomeoneDiscoverJesus:
            
            OnboardingTutorialMediaView(
                viewModel: viewModel.getOnboardingTutorialHelpSomeoneDiscoverJesusViewModel(),
                geometry: geometry,
                screenAccessibilityId: screenAccessibilityId
            )
        }
    }
}

extension OnboardingTutorialView {
    
    func getPageCount() -> Int {
        return viewModel.pages.count
    }
    
    func getCurrentPage() -> OnboardingTutorialPage? {
        return viewModel.getPage(index: viewModel.currentPage)
    }
    
    func getCurrentPageIndex() -> Int {
        return viewModel.currentPage
    }
    
    func getOnboardingTutorialPageAnalyticsProperties(page: OnboardingTutorialPage) -> OnboardingTutorialPageAnalyticsProperties {
        return viewModel.getOnboardingTutorialPageAnalyticsProperties(page: page)
    }
    
    func setCurrentPage(page: Int) {
        viewModel.currentPage = page
    }
}
