//
//  MobileContentPageCollectionPagesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/4/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import UIKit
import GodToolsShared

class MobileContentPageCollectionPagesViewModel: LegacyMobileContentPagesViewModel {

    private let pageCollectionPage: PageCollectionPage
    private let renderedPageContext: MobileContentRenderedPageContext
    
    init(pageCollectionPage: PageCollectionPage, renderedPageContext: MobileContentRenderedPageContext) {

        self.pageCollectionPage = pageCollectionPage
        self.renderedPageContext = renderedPageContext

        super.init()

        super.setPages(pages: pageCollectionPage.pages)
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

    override func pageWillAppear(page: Int, pageParams: MobileContentPageWillAppearParams) -> LegacyMobileContentView? {

        _ = super.pageWillAppear(page: page, pageParams: pageParams)

        let view: LegacyMobileContentView? = renderedPageContext.viewRenderer.recurseAndRender(
            renderableModel: pageCollectionPage.pages[page],
            renderableModelParent: nil,
            renderedPageContext: renderedPageContext
        )

        return view
    }
}
