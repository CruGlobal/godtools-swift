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
    let navigationController: UINavigationController
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController?) {
        print("init: \(type(of: self))")
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController ?? UINavigationController(nibName: nil, bundle: nil)
             
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
            getTutorialUseCase: appDiContainer.domainLayer.getTutorialUseCase(),
            getSettingsPrimaryLanguageUseCase: appDiContainer.domainLayer.getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: appDiContainer.domainLayer.getSettingsParallelLanguageUseCase(),
            analytics: appDiContainer.dataLayer.getAnalytics(),
            tutorialVideoAnalytics: appDiContainer.getTutorialVideoAnalytics()
        )
        
        let view = TutorialView(viewModel: viewModel)
        
        let hostingView = UIHostingController<TutorialView>(rootView: view)
        
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
