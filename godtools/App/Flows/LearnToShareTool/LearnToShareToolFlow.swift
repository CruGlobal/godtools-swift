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
    let navigationController: UINavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, resource: ResourceModel) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = UINavigationController(nibName: nil, bundle: nil)
        
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
        
        let hostingView = UIHostingController<LearnToShareToolView>(rootView: view)
        
        let backButton: UIBarButtonItem = hostingView.addBarButtonItem(
            to: .left,
            image: ImageCatalog.navBack.uiImage,
            color: nil,
            target: viewModel,
            action: #selector(viewModel.backTapped)
        )
        
        _ = hostingView.addBarButtonItem(
            to: .right,
            image: ImageCatalog.navClose.uiImage,
            color: nil,
            target: viewModel,
            action: #selector(viewModel.closeTapped)
        )
        
        viewModel.hidesBackButtonPublisher
            .sink { (backButtonHidden: Bool) in
                
                if backButtonHidden {
                    hostingView.removeBarButtonItem(item: backButton)
                }
                else {
                    hostingView.addBarButtonItem(item: backButton, barPosition: .left)
                }
            }
            .store(in: &cancellables)
        
        return hostingView
    }
}
