//
//  TutorialFlow.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class TutorialFlow: GTFlow {
    
    enum CompletedState: Sendable {
        case closed
    }
                
    init(appDiContainer: AppDiContainer) {
        print("init: \(type(of: self))")
        
        let stepEmitter = FlowStepEmitter()
        
        super.init(
            appDiContainer: appDiContainer,
            initialView: Self.getTutorialView(appDiContainer: appDiContainer, stepEmitter: stepEmitter),
            stepEmitter: stepEmitter,
            navigationController: AppNavigationController(
                navigationBarAppearance: AppNavigationBarAppearance(
                    backgroundColor: .white,
                    controlColor: ColorPalette.gtBlue.uiColor,
                    titleFont: nil,
                    titleColor: nil,
                    isTranslucent: false
                )
            )
        )
                     
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.setNavigationBarHidden(false, animated: false)
    }

    override func navigate(step: FlowStep) {
        
        guard let appStep = step as? AppFlowStep else {
            return
        }

        switch appStep {
                       
        case .closeTappedFromTutorial:
            completeFlow(state: .closed)
            
        case .startUsingGodToolsTappedFromTutorial:
            completeFlow(state: .closed)
            
        default:
            break
        }
    }
    
    private func completeFlow(state: CompletedState) {
        parent?.stepEmitter.emit(step: AppFlowStep.tutorialFlowCompleted(state: state))
    }
}

extension TutorialFlow {
    
    private static func getTutorialView(appDiContainer: AppDiContainer, stepEmitter: FlowStepEmitter) -> UIViewController {
        
        let viewModel = TutorialViewModel(
            stepEmitter: stepEmitter,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getTutorialStringsUseCase: appDiContainer.feature.tutorial.domainLayer.getTutorialStringsUseCase(),
            getTutorialUseCase: appDiContainer.feature.tutorial.domainLayer.getTutorialUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackActionAnalyticsUseCase(),
            tutorialVideoAnalytics: appDiContainer.core.dataLayer.getTutorialVideoAnalytics()
        )
        
        let view = TutorialView(viewModel: viewModel)
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped),
            hidesBarItemPublisher: viewModel.$hidesBackButton.eraseToAnyPublisher()
        )
        
        let closeButton = AppCloseBarItem(
            color: nil,
            target: viewModel,
            action: #selector(viewModel.closeTapped)
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
