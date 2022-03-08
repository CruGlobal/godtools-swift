//
//  MobileContentPagesViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

protocol MobileContentPagesViewModelType {
    
    var numberOfPages: ObservableValue<Int> { get }
    var pageNavigationSemanticContentAttribute: UISemanticContentAttribute { get }
    var rendererWillChangeSignal: Signal { get }
    var pageNavigation: ObservableValue<MobileContentPagesNavigationModel?> { get }
    var pagesRemoved: ObservableValue<[IndexPath]> { get }
    var highestPageNumberViewed: Int { get }
    
    func viewDidFinishLayout(window: UIViewController, safeArea: UIEdgeInsets)
    func pageWillAppear(page: Int) -> MobileContentView?
    func pageDidAppear(page: Int)
    func pageDidDisappear(page: Int)
    func pageDidReceiveEvents(eventIds: [EventId])
    func didChangeMostVisiblePage(page: Int)
}
