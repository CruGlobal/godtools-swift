//
//  LearnToShareToolFlow.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SwiftUI
import Flow

final class LearnToShareToolFlow: GTFlow {
            
    private let tool: ToolDetailsTool
    
    init(
        appDiContainer: AppDiContainer,
        tool: ToolDetailsTool
    ) {
        
        self.tool = tool
        
        let stepEmitter = FlowStepEmitter()
        
        super.init(
            appDiContainer: appDiContainer,
            initialView: Self.getLearnToShareToolView(
                appDiContainer: appDiContainer,
                stepEmitter: stepEmitter,
                tool: tool
            ),
            stepEmitter: stepEmitter,
            navigationController: AppNavigationController(
                navigationBarAppearance: AppNavigationBarAppearance(
                    backgroundColor: .clear,
                    controlColor: ColorPalette.gtBlue.uiColor,
                    titleFont: nil,
                    titleColor: nil,
                    isTranslucent: true
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
            
        case .startTrainingTappedFromLearnToShareTool(let tool):
            parent?.stepEmitter.emit(
                step: AppFlowStep.startTrainingTappedFromLearnToShareTool(tool: tool)
            )
            
        case .closeTappedFromLearnToShareTool(let tool):
            parent?.stepEmitter.emit(
                step: AppFlowStep.closeTappedFromLearnToShareTool(tool: tool)
            )
            
        default:
            break
        }
    }
}

extension LearnToShareToolFlow {
    
    private static func getLearnToShareToolView(
        appDiContainer: AppDiContainer,
        stepEmitter: FlowStepEmitter,
        tool: ToolDetailsTool,
    ) -> UIViewController {
        
        let viewModel = LearnToShareToolViewModel(
            stepEmitter: stepEmitter,
            tool: tool,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getLearnToShareToolStringsUseCase: appDiContainer.feature.learnToShareTool.domainLayer.getLearnToShareToolStringsUseCase(),
            getLearnToShareToolTutorialUseCase: appDiContainer.feature.learnToShareTool.domainLayer.getLearnToShareToolTutorialUseCase()
        )
                
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
        
        let learnToShareToolView = AppHostingController<LearnToShareToolView>(
            rootView: LearnToShareToolView(viewModel: viewModel),
            navigationBar: AppNavigationBar(
                appearance: nil,
                backButton: backButton,
                leadingItems: [],
                trailingItems: [closeButton]
            )
        )
        
        return learnToShareToolView
    }
}
