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
    let selectedLanguage: LanguageDomainModel
    let pageNumber: Int
    let trainingTipsEnabled: Bool
    
    init(renderer: CurrentValueSubject<MobileContentRenderer, Never>, currentPageRenderer: CurrentValueSubject<MobileContentPageRenderer, Never>, tractRemoteSharePublisher: TractRemoteSharePublisher, selectedLanguage: LanguageDomainModel, pageNumber: Int, trainingTipsEnabled: Bool) {
        
        self.renderer = renderer
        self.currentPageRenderer = currentPageRenderer
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        self.selectedLanguage = selectedLanguage
        self.pageNumber = pageNumber
        self.trainingTipsEnabled = trainingTipsEnabled
    }
}
