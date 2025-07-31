//
//  LearnToShareToolFlow.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

class LearnToShareToolFlow: Flow {
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    private let toolPrimaryLanguage: AppLanguageDomainModel
    private let toolParallelLanguage: AppLanguageDomainModel?
    private let toolSelectedLanguageIndex: Int?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, toolId: String, toolPrimaryLanguage: AppLanguageDomainModel, toolParallelLanguage: AppLanguageDomainModel?, toolSelectedLanguageIndex: Int?) {
        
        let navigationBarAppearance = AppNavigationBarAppearance(backgroundColor: .clear, controlColor: ColorPalette.gtBlue.uiColor, titleFont: nil, titleColor: nil, isTranslucent: true)
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = AppNavigationController(navigationBarAppearance: navigationBarAppearance)
        self.toolPrimaryLanguage = toolPrimaryLanguage
        self.toolParallelLanguage = toolParallelLanguage
        self.toolSelectedLanguageIndex = toolSelectedLanguageIndex
        
        navigationController.modalPresentationStyle = .fullScreen
        
        navigationController.setNavigationBarHidden(false, animated: false)
        
        navigationController.setViewControllers([getLearnToShareToolView(toolId: toolId)], animated: false)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .startTrainingTappedFromLearnToShareTool(let toolId, let primaryLanguage, let parallelLanguage, let selectedLanguageIndex):
            flowDelegate?.navigate(step: .startTrainingTappedFromLearnToShareTool(toolId: toolId, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, selectedLanguageIndex: selectedLanguageIndex))
            
        case .closeTappedFromLearnToShareTool(let toolId, let primaryLanguage, let parallelLanguage, let selectedLanguageIndex):
            flowDelegate?.navigate(step: .closeTappedFromLearnToShareTool(toolId: toolId, primaryLanguage: primaryLanguage, parallelLanguage: parallelLanguage, selectedLanguageIndex: selectedLanguageIndex))
            
        default:
            break
        }
    }
    
    private func getLearnToShareToolView(toolId: String) -> UIViewController {
        
        let viewModel = LearnToShareToolViewModel(
            flowDelegate: self,
            toolId: toolId,
            toolPrimaryLanguage: toolPrimaryLanguage,
            toolParallelLanguage: toolParallelLanguage,
            toolSelectedLanguageIndex: toolSelectedLanguageIndex,
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewLearnToShareToolUseCase: appDiContainer.feature.learnToShareTool.domainLayer.getViewLearnToShareToolUseCase()
        )
        
        let view = LearnToShareToolView(viewModel: viewModel)
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped),
            accessibilityIdentifier: nil,
            hidesBarItemPublisher: viewModel.$hidesBackButton.eraseToAnyPublisher()
        )
        
        let closeButton = AppCloseBarItem(
            color: nil,
            target: viewModel,
            action: #selector(viewModel.closeTapped),
            accessibilityIdentifier: nil
        )
        
        let hostingView = AppHostingController<LearnToShareToolView>(
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
