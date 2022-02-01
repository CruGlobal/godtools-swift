//
//  ChooseYourOwnAdventureFlow.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class ChooseYourOwnAdventureFlow: Flow {
    
    private let deepLinkingService: DeepLinkingServiceType
    
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController, resource: ResourceModel, primaryLanguage: LanguageModel, primaryTranslationManifest: TranslationManifestData, parallelLanguage: LanguageModel?, parallelTranslationManifest: TranslationManifestData?) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.deepLinkingService = appDiContainer.getDeepLinkingService()
        
        let translationsFileCache: TranslationsFileCache = appDiContainer.translationsFileCache
        
        let pageViewFactories: MobileContentRendererPageViewFactories = MobileContentRendererPageViewFactories(
            type: .chooseYourOwnAdventure,
            flowDelegate: self,
            appDiContainer: appDiContainer,
            trainingTipsEnabled: false,
            deepLinkingService: deepLinkingService
        )
        
        let primaryRenderer = MobileContentMultiplatformRenderer(
            resource: resource,
            language: primaryLanguage,
            multiplatformParser: MobileContentMultiplatformParser(translationManifestData: primaryTranslationManifest, translationsFileCache: translationsFileCache),
            pageViewFactories: pageViewFactories
        )
        
        var renderers: [MobileContentRendererType] = Array()
        
        renderers.append(primaryRenderer)
        
        if let parallelLanguage = parallelLanguage, let parallelTranslationManifest = parallelTranslationManifest, parallelLanguage.code != primaryLanguage.code {
            
            let parallelRenderer = MobileContentMultiplatformRenderer(
                resource: resource,
                language: parallelLanguage,
                multiplatformParser: MobileContentMultiplatformParser(translationManifestData: parallelTranslationManifest, translationsFileCache: translationsFileCache),
                pageViewFactories: pageViewFactories
            )
                        
            renderers.append(parallelRenderer)
        }
        
        let viewModel = ChooseYourOwnAdventureViewModel(
            flowDelegate: self,
            renderers: renderers,
            primaryLanguage: primaryLanguage,
            page: nil,
            mobileContentEventAnalytics: appDiContainer.getMobileContentEventAnalyticsTracking(),
            localizationServices: appDiContainer.localizationServices
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
