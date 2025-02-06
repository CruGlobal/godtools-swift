//
//  MobileContentPageCollectionPagesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/4/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import UIKit
import GodToolsToolParser

class MobileContentPageCollectionPagesViewModel: MobileContentPagesViewModel {

    private let pageCollectionPage: PageCollectionPage
    private let renderedPageContext: MobileContentRenderedPageContext
    
    init(pageCollectionPage: PageCollectionPage, renderedPageContext: MobileContentRenderedPageContext) {

        self.pageCollectionPage = pageCollectionPage
        self.renderedPageContext = renderedPageContext

        super.init()

        super.setPages(pages: pageCollectionPage.pages)
    }
    
    var initialPageIndex: Int? {
        
        guard let activePageId = renderedPageContext.parentPageParams?.activePageId else {
            return nil
        }
        
        guard let page = super.getPage(pageId: activePageId) else {
            return nil
        }
        
        return pageModels.firstIndex(of: page)
    }
    
    override var layoutDirection: UISemanticContentAttribute {
        return renderedPageContext.primaryLanguageLayoutDirection.semanticContentAttribute
    }

    override func pageDidReceiveEvent(eventId: EventId) -> ProcessedEventResult? {

        let listeningPages: [Page] = pageModels
        let pageToNavigateTo: Page?

        if let listenerPage = getPageToNavigateToForPageListener(listeningPages: listeningPages, eventId: eventId) {

            pageToNavigateTo = listenerPage
        }
        else {

            pageToNavigateTo = nil
        }

        if let pageToNavigateTo = pageToNavigateTo {
            navigateToPage(page: pageToNavigateTo, animated: true)
        }
        
        return nil
    }

    override func pageWillAppear(page: Int, pageParams: MobileContentPageWillAppearParams) -> MobileContentView? {

        _ = super.pageWillAppear(page: page, pageParams: pageParams)

        let view: MobileContentView? = renderedPageContext.viewRenderer.recurseAndRender(
            renderableModel: pageCollectionPage.pages[page],
            renderableModelParent: nil,
            renderedPageContext: renderedPageContext
        )

        return view
    }
}
