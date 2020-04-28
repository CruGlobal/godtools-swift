//
//  FindToolsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class FindToolsViewModel: FindToolsViewModelType {
    
    private let analytics: GodToolsAnaltyics
    
    private weak var flowDelegate: FlowDelegate?
    
    required init(flowDelegate: FlowDelegate, analytics: GodToolsAnaltyics) {
        
        self.flowDelegate = flowDelegate
        self.analytics = analytics
    }
    
    func pageViewed() {
        analytics.recordScreenView(screenName: "Find Tools", siteSection: "tools", siteSubSection: "")
    }
    
    func toolTapped(resource: DownloadedResource) {
        flowDelegate?.navigate(step: .toolTappedFromFindTools(resource: resource))
    }
    
    func toolInfoTapped(resource: DownloadedResource) {
        flowDelegate?.navigate(step: .toolInfoTappedFromFindTools(resource: resource))
    }
}
