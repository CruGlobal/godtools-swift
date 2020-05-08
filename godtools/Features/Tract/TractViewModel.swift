//
//  TractViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TractViewModel: TractViewModelType {
    
    private let analytics: AnalyticsContainer
    private let toolOpenedAnalytics: ToolOpenedAnalytics
    
    let resource: DownloadedResource
    let navTitle: ObservableValue<String> = ObservableValue(value: "God Tools")
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, resource: DownloadedResource, analytics: AnalyticsContainer, toolOpenedAnalytics: ToolOpenedAnalytics) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.analytics = analytics
        self.toolOpenedAnalytics = toolOpenedAnalytics
    }
    
    func navHomeTapped() {
        flowDelegate?.navigate(step: .homeTappedFromTract)
    }
    
    func viewLoaded() {
        
        toolOpenedAnalytics.trackFirstToolOpenedIfNeeded()
        toolOpenedAnalytics.trackToolOpened()
    }
}
