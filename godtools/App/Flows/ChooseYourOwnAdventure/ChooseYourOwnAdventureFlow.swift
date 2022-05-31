//
//  ChooseYourOwnAdventureFlow.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class ChooseYourOwnAdventureFlow: Flow {
    
    private let deepLinkingService: DeepLinkingServiceType
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController, toolTranslations: ToolTranslations) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.deepLinkingService = appDiContainer.getDeepLinkingService()
                    
        let renderer: MobileContentRenderer = appDiContainer.getMobileContentRenderer(
            flowDelegate: self,
            deepLinkingService: deepLinkingService,
            type: .chooseYourOwnAdventure,
            toolTranslations: toolTranslations
        )
        
        let viewModel = ChooseYourOwnAdventureViewModel(
            flowDelegate: self,
            renderer: renderer,
            page: nil,
            mobileContentEventAnalytics: appDiContainer.getMobileContentEventAnalyticsTracking(),
            localizationServices: appDiContainer.localizationServices,
            fontService: appDiContainer.getFontService(),
            trainingTipsEnabled: false
        )
        
        let view = ChooseYourOwnAdventureView(viewModel: viewModel)
        
        sharedNavigationController.pushViewController(view, animated: true)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
        case .backTappedFromChooseYourOwnAdventure:
            
            flowDelegate?.navigate(step: .chooseYourOwnAdventureFlowCompleted(state: .userClosedTool))
            
        default:
            break
        }
    }
}
