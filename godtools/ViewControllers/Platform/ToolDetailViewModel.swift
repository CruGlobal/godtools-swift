//
//  ToolDetailViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ToolDetailViewModel: ToolDetailViewModelType {
    
    private let analytics: GodToolsAnaltyics
    
    private weak var flowDelegate: FlowDelegate?
    
    let resource: DownloadedResource
    let hidesOpenToolButton: Bool
    
    required init(flowDelegate: FlowDelegate, resource: DownloadedResource, analytics: GodToolsAnaltyics) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.analytics = analytics
        self.hidesOpenToolButton = !resource.shouldDownload
    }
    
    func urlTapped(url: URL) {
        
        analytics.recordExitLinkAction(url: url)
        
        flowDelegate?.navigate(step: .urlLinkTappedFromToolDetail(url: url))
    }
}
