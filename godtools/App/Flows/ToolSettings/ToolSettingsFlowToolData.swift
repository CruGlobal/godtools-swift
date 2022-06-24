//
//  ToolSettingsFlowToolData.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//
import Foundation
import GodToolsToolParser
import Combine

class ToolSettingsFlowToolData {
    
    let renderer: CurrentValueSubject<MobileContentRenderer, Never>
    let currentPageRenderer: CurrentValueSubject<MobileContentPageRenderer, Never>
    let tractRemoteSharePublisher: TractRemoteSharePublisher
    let pageNumber: Int
    let trainingTipsEnabled: Bool
    
    required init(renderer: CurrentValueSubject<MobileContentRenderer, Never>, currentPageRenderer: CurrentValueSubject<MobileContentPageRenderer, Never>, tractRemoteSharePublisher: TractRemoteSharePublisher, pageNumber: Int, trainingTipsEnabled: Bool) {
        
        self.renderer = renderer
        self.currentPageRenderer = currentPageRenderer
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        self.pageNumber = pageNumber
        self.trainingTipsEnabled = trainingTipsEnabled
    }
}
