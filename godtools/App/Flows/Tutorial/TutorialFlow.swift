//
//  TutorialFlow.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

class TutorialFlow: Flow {
        
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: AppNavigationController?) {
        print("init: \(type(of: self))")
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController ?? AppNavigationController(navigationBarAppearance: nil)
             
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.setNavigationBarHidden(false, animated: false)
        navigationController.navigationBar.setupNavigationBarAppearance(
            backgroundColor: .white,
            controlColor: ColorPalette.gtBlue.uiColor,
            titleFont: nil,
            titleColor: nil,
            isTranslucent: false
        )
               
        navigationController.setViewControllers(
            [getTutorialView()],
            animated: sharedNavigationController != nil
        )
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
           
        case .closeTappedFromTutorial:
            flowDelegate?.navigate(step: .closeTappedFromTutorial)
            
        case .startUsingGodToolsTappedFromTutorial:
            flowDelegate?.navigate(step: .startUsingGodToolsTappedFromTutorial)
            
        default:
            break
        }
    }
}

extension TutorialFlow {
    
    private func getTutorialView() -> UIViewController {
        
        let viewModel = TutorialViewModel(
            flowDelegate: self,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getTutorialUseCase: appDiContainer.feature.tutorial.domainLayer.getTutorialUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase(),
            tutorialVideoAnalytics: appDiContainer.dataLayer.getTutorialVideoAnalytics()
        )
        
        let view = TutorialView(viewModel: viewModel)
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped),
            accessibilityIdentifier: nil,
            toggleVisibilityPublisher: viewModel.hidesBackButtonPublisher
        )
        
        let closeButton = AppCloseBarItem(
            color: nil,
            target: viewModel,
            action: #selector(viewModel.closeTapped),
            accessibilityIdentifier: nil
        )
        
        let hostingView = AppHostingController<TutorialView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: backButton,
                leadingItems: [],
                trailingItems: [closeButton]
            )
        )
        
        return hostingView
    }
}
