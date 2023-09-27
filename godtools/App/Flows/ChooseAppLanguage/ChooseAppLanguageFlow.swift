//
//  ChooseAppLanguageFlow.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

class ChooseAppLanguageFlow: Flow {
    
    private let didChooseAppLanguageSubject: PassthroughSubject<AppLanguageListItemDomainModel, Never>
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController, didChooseAppLanguageSubject: PassthroughSubject<AppLanguageListItemDomainModel, Never>) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.didChooseAppLanguageSubject = didChooseAppLanguageSubject
        
        sharedNavigationController.pushViewController(getAppLanguagesView(), animated: true)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .backTappedFromAppLanguages:
            flowDelegate?.navigate(step: .chooseAppLanguageFlowCompleted(state: .userClosedChooseAppLanguage))
            
        case .appLanguageTappedFromAppLanguages(let appLanguage):
                 
            // TODO: Need to set the language direction based on the tapped app language. ~Levi
            //ApplicationLayout.setLayoutDirection(direction: appLanguage.direction == .leftToRight ? .leftToRight : .rightToLeft)
            
            didChooseAppLanguageSubject.send(appLanguage)
            
            flowDelegate?.navigate(step: .chooseAppLanguageFlowCompleted(state: .userChoseAppLanguage(appLanguage: appLanguage)))
            
        default:
            break
        }
    }
}

extension ChooseAppLanguageFlow {
    
    func getAppLanguagesView() -> UIViewController {
        
        let viewModel = AppLanguagesViewModel(
            flowDelegate: self,
            getAppLanguagesListUseCase: appDiContainer.feature.appLanguage.domainLayer.getAppLanguagesListUseCase()
        )
        
        let view = AppLanguagesView(viewModel: viewModel)
        
        let hostingView: UIHostingController<AppLanguagesView> = UIHostingController(rootView: view)
        
        _ = hostingView.addDefaultNavBackItem(
            target: viewModel,
            action: #selector(viewModel.backTapped)
        )
        
        return hostingView
    }
}
