//
//  MobileContentPagesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentPagesViewModel: NSObject, MobileContentPagesViewModelType {
    
    private let startingPage: Int?
    
    private var currentRenderer: MobileContentRenderer?
    private var safeArea: UIEdgeInsets?
    private weak var window: UIViewController?
    private weak var flowDelegate: FlowDelegate?
    
    let renderers: [MobileContentRenderer]
    let numberOfPages: ObservableValue<Int> = ObservableValue(value: 0)
    let pageNavigationSemanticContentAttribute: UISemanticContentAttribute
    let rendererWillChangeSignal: Signal = Signal()
    let pageNavigation: ObservableValue<MobileContentPagesNavigationModel?> = ObservableValue(value: nil)
    
    required init(flowDelegate: FlowDelegate, renderers: [MobileContentRenderer], primaryLanguage: LanguageModel, page: Int?) {
        
        self.flowDelegate = flowDelegate
        self.renderers = renderers
        self.startingPage = page
        
        switch primaryLanguage.languageDirection {
        case .leftToRight:
            pageNavigationSemanticContentAttribute = .forceLeftToRight
        case .rightToLeft:
            pageNavigationSemanticContentAttribute = .forceRightToLeft
        }
        
        super.init()
    }
    
    func viewDidFinishLayout(window: UIViewController, safeArea: UIEdgeInsets) {
        
        self.window = window
        self.safeArea = safeArea
        
        guard let renderer = renderers.first else {
            return
        }
        
        if let startingPage = startingPage {
            let navigationModel = MobileContentPagesNavigationModel(
                willReloadData: true,
                page: startingPage,
                pagePositions: nil,
                animated: false
            )
            pageNavigation.accept(value: navigationModel)
        }
        
        setRenderer(renderer: renderer)
    }
    
    func getPageForListenerEvents(events: [String]) -> Int? {
        return currentRenderer?.getPageForListenerEvents(events: events)
    }
    
    func setRenderer(renderer: MobileContentRenderer) {
        
        rendererWillChangeSignal.accept()
        
        currentRenderer = renderer
        
        numberOfPages.accept(value: renderer.numberOfPages)
    }
    
    func pageWillAppear(page: Int) -> MobileContentView? {
        
        guard let window = self.window, let safeArea = self.safeArea else {
            return nil
        }
        
        guard let renderer = self.currentRenderer else {
            return nil
        }
        
        let renderPageResult: Result<MobileContentView, Error> = renderer.renderPage(page: page, window: window, safeArea: safeArea)
        
        switch renderPageResult {
        
        case .success(let mobileContentView):
            return mobileContentView
            
        case .failure(let error):
            break
        }
        
        return nil
    }
    
    func buttonWithUrlTapped(url: String) {
        flowDelegate?.navigate(step: .buttonWithUrlTappedFromMobileContentRenderer(url: url))
    }
    
    func trainingTipTapped(event: TrainingTipEvent) {
        flowDelegate?.navigate(step: .trainingTipTappedFromMobileContentRenderer(event: event))
    }
    
    func errorOccurred(error: MobileContentErrorViewModel) {
        flowDelegate?.navigate(step: .errorOccurredFromMobileContentRenderer(error: error))
    }
}
