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
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, resource: ResourceModel) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = AppNavigationController()
        
        navigationController.modalPresentationStyle = .fullScreen
        
        navigationController.setNavigationBarHidden(false, animated: false)
        
        navigationController.navigationBar.setupNavigationBarAppearance(
            backgroundColor: .clear,
            controlColor: ColorPalette.gtBlue.uiColor,
            titleFont: nil,
            titleColor: nil,
            isTranslucent: true
        )
        
        navigationController.setViewControllers([getLearnToShareToolView(resource: resource)], animated: false)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .continueTappedFromLearnToShareTool(let resource):
            flowDelegate?.navigate(step: .continueTappedFromLearnToShareTool(resource: resource))
            
        case .closeTappedFromLearnToShareTool(let resource):
            flowDelegate?.navigate(step: .closeTappedFromLearnToShareTool(resource: resource))
            
        default:
            break
        }
    }
    
    private func getLearnToShareToolView(resource: ResourceModel) -> UIViewController {
        
        let viewModel = LearnToShareToolViewModel(
            flowDelegate: self,
            resource: resource,
            getLearnToShareToolItemsUseCase: appDiContainer.domainLayer.getLearnToShareToolItemsUseCase(),
            localizationServices: appDiContainer.dataLayer.getLocalizationServices()
        )
        
        let view = LearnToShareToolView(viewModel: viewModel)
        
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
        
        let hostingView = AppHostingController<LearnToShareToolView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                backButton: backButton,
                leadingItems: [],
                trailingItems: [closeButton]
            )
        )
        
        return hostingView
    }
}
