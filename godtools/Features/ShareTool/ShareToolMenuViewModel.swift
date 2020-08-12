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
    private let resource: ResourceModel
    private let language: LanguageModel
    private let pageNumber: Int
    
    private weak var flowDelegate: FlowDelegate?
    
    let shareToolTitle: String = "Send this tool"
    let remoteShareToolTitle: String = "Share your screen"
    let cancelTitle: String = "Cancel"
    
    required init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices, resource: ResourceModel, language: LanguageModel, pageNumber: Int) {
        
        self.flowDelegate = flowDelegate
        self.localizationServices = localizationServices
        self.resource = resource
        self.language = language
        self.pageNumber = pageNumber
    }
    
    func shareToolTapped() {
        
        flowDelegate?.navigate(step: .shareToolTappedFromShareToolMenu(resource: resource, language: language, pageNumber: pageNumber))
    }
    
    func remoteShareToolTapped() {
        
        flowDelegate?.navigate(step: .remoteShareToolTappedFromShareToolMenu)
    }
}
