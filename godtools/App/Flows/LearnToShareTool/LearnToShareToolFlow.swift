//
//  LearnToShareToolFlow.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SwiftUI

final class LearnToShareToolFlow: GTFlow {
            
    private let toolPrimaryLanguage: AppLanguageDomainModel
    private let toolParallelLanguage: AppLanguageDomainModel?
    private let toolSelectedLanguageIndex: Int?
        
    init(
        appDiContainer: AppDiContainer,
        toolId: String,
        toolPrimaryLanguage: AppLanguageDomainModel,
        toolParallelLanguage: AppLanguageDomainModel?,
        toolSelectedLanguageIndex: Int?
    ) {
        
        self.toolPrimaryLanguage = toolPrimaryLanguage
        self.toolParallelLanguage = toolParallelLanguage
        self.toolSelectedLanguageIndex = toolSelectedLanguageIndex
        
        let stepEmitter = FlowStepEmitter()
        
        super.init(
            appDiContainer: appDiContainer,
            initialView: Self.getLearnToShareToolView(
                appDiContainer: appDiContainer,
                stepEmitter: stepEmitter,
                toolId: toolId,
                toolPrimaryLanguage: toolPrimaryLanguage,
                toolParallelLanguage: toolParallelLanguage,
                toolSelectedLanguageIndex: toolSelectedLanguageIndex
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
            
        case .startTrainingTappedFromLearnToShareTool(let toolId, let primaryLanguage, let parallelLanguage, let selectedLanguageIndex):
            parent?.stepEmitter.emit(step: AppFlowStep.startTrainingTappedFromLearnToShareTool(toolId: toolId, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, selectedLanguageIndex: selectedLanguageIndex))
            
        case .closeTappedFromLearnToShareTool(let toolId, let primaryLanguage, let parallelLanguage, let selectedLanguageIndex):
            parent?.stepEmitter.emit(step: AppFlowStep.closeTappedFromLearnToShareTool(toolId: toolId, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, selectedLanguageIndex: selectedLanguageIndex))
            
        default:
            break
        }
    }
}

extension LearnToShareToolFlow {
    
    private static func getLearnToShareToolView(
        appDiContainer: AppDiContainer,
        stepEmitter: FlowStepEmitter,
        toolId: String,
        toolPrimaryLanguage: AppLanguageDomainModel,
        toolParallelLanguage: AppLanguageDomainModel?,
        toolSelectedLanguageIndex: Int?
    ) -> UIViewController {
        
        let viewModel = LearnToShareToolViewModel(
            stepEmitter: stepEmitter,
            toolId: toolId,
            toolPrimaryLanguage: toolPrimaryLanguage,
            toolParallelLanguage: toolParallelLanguage,
            toolSelectedLanguageIndex: toolSelectedLanguageIndex,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getLearnToShareToolStringsUseCase: appDiContainer.feature.learnToShareTool.domainLayer.getLearnToShareToolStringsUseCase(),
            getLearnToShareToolTutorialUseCase: appDiContainer.feature.learnToShareTool.domainLayer.getLearnToShareToolTutorialUseCase()
        )
                
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped),
            accessibilityIdentifier: nil,
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
