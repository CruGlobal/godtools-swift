//
//  ToolCardViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

@MainActor class ToolCardViewModel: ObservableObject {
        
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let attachmentsRepository: AttachmentsRepository
                
    let attachmentBanner: AttachmentBannerObservableObject
    let tool: ToolListItemDomainModelInterface
    let accessibilityWithToolName: String
    
    @Published private(set) var isFavorited = false
    @Published private(set) var name: String = ""
    @Published private(set) var category: String = ""
    @Published private(set) var languageAvailability: String?
    @Published private(set) var detailsButtonTitle: String = ""
    @Published private(set) var openButtonTitle: String = ""
            
    init(tool: ToolListItemDomainModelInterface, accessibility: AccessibilityStrings.Button, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, attachmentsRepository: AttachmentsRepository) {
        
        self.tool = tool
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.attachmentsRepository = attachmentsRepository
                        
        name = tool.name
        category = tool.category
        languageAvailability = tool.languageAvailability?.availabilityString
        isFavorited = tool.isFavorited
        openButtonTitle = tool.interfaceStrings.openToolActionTitle
        detailsButtonTitle = tool.interfaceStrings.openToolDetailsActionTitle
        
        accessibilityWithToolName = AccessibilityStrings.Button.getToolButtonAccessibility(toolButton: accessibility, toolName: tool.name)
        
        attachmentBanner = AttachmentBannerObservableObject(
            attachmentId: tool.bannerImageId,
            attachmentsRepository: attachmentsRepository
        )
                
        getToolIsFavoritedUseCase
            .getToolIsFavoritedPublisher(toolId: tool.dataModelId)
            .map { $0.isFavorited }
            .receive(on: DispatchQueue.main)
            .assign(to: &$isFavorited)
    }
}
