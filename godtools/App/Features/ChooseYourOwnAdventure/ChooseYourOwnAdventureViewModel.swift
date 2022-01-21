//
//  ChooseYourOwnAdventureViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class ChooseYourOwnAdventureViewModel: MobileContentPagesViewModel, ChooseYourOwnAdventureViewModelType {
    
    required init(flowDelegate: FlowDelegate, renderers: [MobileContentRendererType], primaryLanguage: LanguageModel, page: Int?, mobileContentEventAnalytics: MobileContentEventAnalyticsTracking) {
        
        super.init(flowDelegate: flowDelegate, renderers: renderers, primaryLanguage: primaryLanguage, page: page, mobileContentEventAnalytics: mobileContentEventAnalytics)
    }
}
