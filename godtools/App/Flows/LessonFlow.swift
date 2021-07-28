//
//  LessonFlow.swift
//  godtools
//
//  Created by Levi Eggert on 7/27/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class LessonFlow: NSObject, ToolNavigationFlow, Flow {
    
    private let deepLinkingService: DeepLinkingServiceType
        
    private weak var flowDelegate: FlowDelegate?
    
    let appDiContainer: AppDiContainer
    let navigationController: UINavigationController
    
    var articleFlow: ArticleFlow?
    var lessonFlow: LessonFlow?
    var tractFlow: TractFlow?
    
    required init(flowDelegate: FlowDelegate, appDiContainer: AppDiContainer, sharedNavigationController: UINavigationController, resource: ResourceModel, primaryLanguage: LanguageModel, primaryTranslationManifest: TranslationManifestData, trainingTipsEnabled: Bool, page: Int?) {
        
        self.flowDelegate = flowDelegate
        self.appDiContainer = appDiContainer
        self.navigationController = sharedNavigationController
        self.deepLinkingService = appDiContainer.getDeepLinkingService()
        
        super.init()
        
        let pageViewFactories: MobileContentRendererPageViewFactories = MobileContentRendererPageViewFactories(
            type: .lesson,
            flowDelegate: self,
            appDiContainer: appDiContainer,
            trainingTipsEnabled: trainingTipsEnabled,
            deepLinkingService: deepLinkingService
        )
        
        let translationsFileCache: TranslationsFileCache = appDiContainer.translationsFileCache
                
        let renderer = MobileContentXmlNodeRenderer(
            resource: resource,
            language: primaryLanguage,
            xmlParser: MobileContentXmlParser(translationManifestData: primaryTranslationManifest, translationsFileCache: translationsFileCache),
            pageViewFactories: pageViewFactories
        )
        
        let viewModel = LessonViewModel(
            flowDelegate: self,
            renderers: [renderer],
            resource: resource,
            primaryLanguage: primaryLanguage,
            page: page
        )
        
        let view = LessonView(viewModel: viewModel)
        
        navigationController.pushViewController(view, animated: true)
        
        configureNavigationBar(shouldAnimateNavigationBarHiddenState: true)
        
        addDeepLinkingObserver()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        deepLinkingService.completed.removeObserver(self)
    }
    
    private func configureNavigationBar(shouldAnimateNavigationBarHiddenState: Bool) {
        navigationController.setNavigationBarHidden(true, animated: shouldAnimateNavigationBarHiddenState)
    }
    
    private func addDeepLinkingObserver() {
        deepLinkingService.completed.addObserver(self) { [weak self] (parsedDeepLink: ParsedDeepLinkType?) in
            if let deepLink = parsedDeepLink {
                self?.navigate(step: .deepLink(deepLinkType: deepLink))
            }
        }
    }
    
    func navigate(step: FlowStep) {
        
        switch step {
        
        case .deepLink(let deepLink):
            
            switch deepLink {
            
            case .allToolsList:
                break
            
            case .article(let articleURI):
                break
            
            case .favoritedToolsList:
                break
            
            case .lessonsList:
                break
            
            case .tool(let toolDeepLink):
                
                guard let toolDeepLinkResources = ToolDeepLinkResources(dataDownloader: appDiContainer.initialDataDownloader, languageSettingsService: appDiContainer.languageSettingsService, toolDeepLink: toolDeepLink) else {
                    return
                }
                
                navigateToTool(
                    resource: toolDeepLinkResources.resource,
                    primaryLanguage: toolDeepLinkResources.primaryLanguage,
                    parallelLanguage: toolDeepLinkResources.parallelLanguage,
                    liveShareStream: toolDeepLink.liveShareStream,
                    trainingTipsEnabled: false,
                    page: toolDeepLink.page
                )
            }
        
        case .closeTappedFromLesson:
            flowDelegate?.navigate(step: .lessonFlowCompleted(state: .userClosedLesson))
            
        case .buttonWithUrlTappedFromMobileContentRenderer(let url, let exitLink):
            guard let webUrl = URL(string: url) else {
                return
            }
            navigateToURL(url: webUrl, exitLink: exitLink)
                        
        case .errorOccurredFromMobileContentRenderer(let error):
            
            let view = MobileContentErrorView(viewModel: error)
            
            navigationController.present(view.controller, animated: true, completion: nil)
            
        case .articleFlowCompleted(let state):
            
            guard articleFlow != nil else {
                return
            }
            
            _ = navigationController.popViewController(animated: true)
            configureNavigationBar(shouldAnimateNavigationBarHiddenState: true)
            
            articleFlow = nil
            
        case .tractFlowCompleted(let state):
            
            guard tractFlow != nil else {
                return
            }

            _ = navigationController.popViewController(animated: true)
            configureNavigationBar(shouldAnimateNavigationBarHiddenState: true)
            
            tractFlow = nil
                    
        default:
            break
        }
    }
}
