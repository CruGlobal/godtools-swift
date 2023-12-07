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
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, tool: ToolDomainModel) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = AppNavigationController(navigationBarAppearance: nil)
        
        navigationController.modalPresentationStyle = .fullScreen
        
        navigationController.setNavigationBarHidden(false, animated: false)
        
        navigationController.navigationBar.setupNavigationBarAppearance(
            backgroundColor: .clear,
            controlColor: ColorPalette.gtBlue.uiColor,
            titleFont: nil,
            titleColor: nil,
            isTranslucent: true
        )
        
        navigationController.setViewControllers([getLearnToShareToolView(tool: tool)], animated: false)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .continueTappedFromLearnToShareTool(let tool):
            flowDelegate?.navigate(step: .continueTappedFromLearnToShareTool(tool: tool))
            
        case .closeTappedFromLearnToShareTool(let tool):
            flowDelegate?.navigate(step: .closeTappedFromLearnToShareTool(tool: tool))
            
        default:
            break
        }
    }
    
    private func getLearnToShareToolView(tool: ToolDomainModel) -> UIViewController {
        
        let viewModel = LearnToShareToolViewModel(
            flowDelegate: self,
            tool: tool,
            getLearnToShareToolItemsUseCase: appDiContainer.domainLayer.getLearnToShareToolItemsUseCase(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices()
        )
        
        let view = LearnToShareToolView(viewModel: viewModel)
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped),
            accessibilityIdentifier: nil,
            toggleVisibilityPublisher: viewModel.$hidesBackButton.eraseToAnyPublisher()
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
