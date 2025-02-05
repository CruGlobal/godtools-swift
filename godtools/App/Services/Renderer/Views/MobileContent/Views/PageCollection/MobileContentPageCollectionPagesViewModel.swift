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

        super.init(pagesNavigation: renderedPageContext.pagesNavigation)

        super.setPages(pages: pageCollectionPage.pages)
    }

    override var layoutDirection: UISemanticContentAttribute {
        return renderedPageContext.primaryLanguageLayoutDirection.semanticContentAttribute
    }

    override func pageDidReceiveEvent(eventId: EventId) -> ProcessedEventResult? {

        return nil
    }

    override func pageWillAppear(page: Int) -> MobileContentView? {

        _ = super.pageWillAppear(page: page)

        let view: MobileContentView? = renderedPageContext.viewRenderer.recurseAndRender(
            renderableModel: pageCollectionPage.pages[page],
            renderableModelParent: nil,
            renderedPageContext: renderedPageContext
        )

        return view
    }
}
