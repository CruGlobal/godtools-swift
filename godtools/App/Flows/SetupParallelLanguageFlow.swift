//
//  SetupParallelLanguageFlow.swift
//  godtools
//
//  Created by Robert Eldredge on 11/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class SetupParallelLanguageFlow: Flow {
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController?) {
        print("init: \(type(of: self))")
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController ?? UINavigationController(nibName: nil, bundle: nil)
             
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.setNavigationBarHidden(false, animated: false)
        navigationController.navigationBar.setupNavigationBarAppearance(
            backgroundColor: .white,
            controlColor: nil,
            titleFont: nil,
            titleColor: nil,
            isTranslucent: false
        )
        
        let viewModel = SetupParallelLanguageViewModel(flowDelegate: self, localizationServices: appDiContainer.localizationServices)
        
        let view = SetupParallelLanguageView(viewModel: viewModel)
                
        let animated: Bool = sharedNavigationController != nil
        navigationController.setViewControllers([view], animated: animated)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
        
        case .selectLanguageTappedFromSetupParallelLanguage:
            presentParallelLanguageModal()
        
        case .languageSelectedFromSetupParallelLanguage:
            navigationController.dismiss(animated: true, completion: nil)
        
        case .closeTappedFromSetupParallelLanguage:
            flowDelegate?.navigate(step: .dismissSetupParallelLanguage)
        
        case .noThanksTappedFromSetupParallelLanguage:
            flowDelegate?.navigate(step: .dismissSetupParallelLanguage)
        
        case .getStartedTappedFromSetupParallelLanguage:
            flowDelegate?.navigate(step: .dismissSetupParallelLanguage)
        
        default:
            break
        }
    }
    
    private func presentParallelLanguageModal() {
        
        let viewModel = ParallelLanguageModalViewModel(
            flowDelegate: self,
            dataDownloader: appDiContainer.initialDataDownloader,
            languageSettingsService: appDiContainer.languageSettingsService,
            localizationServices: appDiContainer.localizationServices
        )
        let view = ParallelLanguageModal(viewModel: viewModel)
        
        let modal = TransparentModalView(modalView: view)
        
        navigationController.present(modal, animated: true, completion: nil)
    }
}

