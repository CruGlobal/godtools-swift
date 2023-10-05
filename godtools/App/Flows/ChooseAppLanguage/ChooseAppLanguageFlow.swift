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
    
    private static var setAppLanguageInBackgroundCancellable: AnyCancellable?
        
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: AppNavigationController
    
    init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: AppNavigationController) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        
        sharedNavigationController.pushViewController(getAppLanguagesView(), animated: true)
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
            
        case .backTappedFromAppLanguages:
            flowDelegate?.navigate(step: .chooseAppLanguageFlowCompleted(state: .userClosedChooseAppLanguage))
            
        case .appLanguageTappedFromAppLanguages(let appLanguage):
            
            let setAppLanguageUseCase: SetAppLanguageUseCase = appDiContainer.feature.appLanguage.domainLayer.getSetAppLanguageUseCase()
            
            ChooseAppLanguageFlow.setAppLanguageInBackgroundCancellable = setAppLanguageUseCase.setLanguagePublisher(language: appLanguage.languageCode)
                .sink(receiveValue: { _ in

                })
                        
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
        
        let backButton = AppBackBarItem(
            target: viewModel,
            action: #selector(viewModel.backTapped),
            accessibilityIdentifier: nil
        )
        
        let hostingView = AppHostingController<AppLanguagesView>(
            rootView: view,
            navigationBar: AppNavigationBar(
                backButton: backButton,
                leadingItems: [],
                trailingItems: []
            )
        )
        
        return hostingView
    }
}
