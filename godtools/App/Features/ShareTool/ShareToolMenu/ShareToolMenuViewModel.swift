//
//  ShareToolMenuViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ShareToolMenuViewModel: ShareToolMenuViewModelType {
    
    private let localizationServices: LocalizationServices
    
    private weak var flowDelegate: FlowDelegate?
    
    let shareToolTitle: String
    let remoteShareToolTitle: String
    let cancelTitle: String
    let hidesRemoteShareToolAction: Bool
    
    required init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices, hidesRemoteShareToolAction: Bool) {
        
        self.flowDelegate = flowDelegate
        self.localizationServices = localizationServices
        self.hidesRemoteShareToolAction = hidesRemoteShareToolAction
        
        shareToolTitle = localizationServices.stringForMainBundle(key: "share_tool_menu.send_tool")
        remoteShareToolTitle = localizationServices.stringForMainBundle(key: "share_tool_menu.remote_share_tool")
        cancelTitle = localizationServices.stringForMainBundle(key: "cancel")
    }
    
    func shareToolTapped() {
        
        flowDelegate?.navigate(step: .shareToolTappedFromShareToolMenu)
    }
    
    func remoteShareToolTapped() {
        
        flowDelegate?.navigate(step: .remoteShareToolTappedFromShareToolMenu)
    }
}
