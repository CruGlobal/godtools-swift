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
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController, resource: ResourceModel, primaryLanguage: LanguageModel, primaryLanguageManifest: Manifest, parallelLanguage: LanguageModel?, parallelLanguageManifest: Manifest?) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.deepLinkingService = appDiContainer.getDeepLinkingService()
            
        var languageTranslationManifests: [MobileContentRendererLanguageTranslationManifest] = Array()
        
        let primaryLanguageTranslationManifest = MobileContentRendererLanguageTranslationManifest(
            manifest: primaryLanguageManifest,
            language: primaryLanguage
        )
        
        languageTranslationManifests.append(primaryLanguageTranslationManifest)
        
        if let manifest = parallelLanguageManifest, let language = parallelLanguage {
            languageTranslationManifests.append(MobileContentRendererLanguageTranslationManifest(manifest: manifest, language: language))
        }
        
        let renderer: MobileContentRenderer = appDiContainer.getMobileContentRenderer(
            flowDelegate: self,
            deepLinkingService: deepLinkingService,
            type: .chooseYourOwnAdventure,
            resource: resource,
            primaryLanguage: primaryLanguage,
            languageTranslationManifests: languageTranslationManifests
        )
        
        let viewModel = ChooseYourOwnAdventureViewModel(
            flowDelegate: self,
            primaryManifest: primaryLanguageManifest,
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
