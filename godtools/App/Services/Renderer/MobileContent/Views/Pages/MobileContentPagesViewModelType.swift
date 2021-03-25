//
//  MobileContentPagesViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol MobileContentPagesViewModelType {
    
    var numberOfPages: ObservableValue<Int> { get }
    var pageNavigationSemanticContentAttribute: UISemanticContentAttribute { get }
    var rendererWillChangeSignal: Signal { get }
    var pageNavigation: ObservableValue<MobileContentPagesNavigationModel?> { get }
    
    func viewDidFinishLayout(window: UIViewController, safeArea: UIEdgeInsets)
    func getPageForListenerEvents(events: [String]) -> Int?
    func pageWillAppear(page: Int) -> MobileContentView?
    func buttonWithUrlTapped(url: String)
    func trainingTipTapped(event: TrainingTipEvent)
    func errorOccurred(error: MobileContentErrorViewModel)
}
