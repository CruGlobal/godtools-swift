//
//  MobileContentPagesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentPagesViewModel: MobileContentPagesViewModelType {
    
    private let renderers: [MobileContentRenderer]
    
    private var currentRenderer: MobileContentRenderer?
    private var safeArea: UIEdgeInsets?
    private weak var window: UIViewController?
    
    let numberOfPages: ObservableValue<Int> = ObservableValue(value: 0)
    let currentPage: ObservableValue<AnimatableValue<Int>> = ObservableValue(value: AnimatableValue(value: 0, animated: false))
    let pageNavigationSemanticContentAttribute: UISemanticContentAttribute
    
    required init(renderers: [MobileContentRenderer], primaryLanguage: LanguageModel, page: Int?) {
        
        self.renderers = renderers
        
        switch primaryLanguage.languageDirection {
        case .leftToRight:
            pageNavigationSemanticContentAttribute = .forceLeftToRight
        case .rightToLeft:
            pageNavigationSemanticContentAttribute = .forceRightToLeft
        }
    }
    
    private func setRenderer(renderer: MobileContentRenderer) {
        
        currentRenderer = renderer
        
        numberOfPages.accept(value: renderer.numberOfPages)
    }
    
    private var currentPageValue: Int {
        get {
            return currentPage.value.value
        }
        set(newValue) {
            currentPage.setValue(value: AnimatableValue(value: newValue, animated: false))
        }
    }
    
    func viewDidFinishLayout(window: UIViewController, safeArea: UIEdgeInsets) {
        
        self.window = window
        self.safeArea = safeArea
        
        guard let renderer = renderers.first else {
            return
        }
        
        setRenderer(renderer: renderer)
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
    
    func pageDidChange(page: Int) {
        
        self.currentPageValue = page
    }
    
    func pageDidAppear(page: Int) {
        
        self.currentPageValue = page
    }
}
