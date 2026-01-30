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
    
    private var cancellables: Set<AnyCancellable> = Set()

    let tool: ToolListItemDomainModelInterface
    let accessibilityWithToolName: String
    
    @Published private(set) var banner: OptionalImageData?
    @Published private(set) var isFavorited = false
    @Published private(set) var name: String = ""
    @Published private(set) var category: String = ""
    @Published private(set) var languageAvailability: String?
    @Published private(set) var detailsButtonTitle: String = ""
    @Published private(set) var openButtonTitle: String = ""
            
    init(tool: ToolListItemDomainModelInterface, accessibility: AccessibilityStrings.Button, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, getToolBannerUseCase: GetToolBannerUseCase) {
        
        self.tool = tool
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
                        
        name = tool.name
        category = tool.category
        languageAvailability = tool.languageAvailability?.availabilityString
        isFavorited = tool.isFavorited
        openButtonTitle = tool.interfaceStrings.openToolActionTitle
        detailsButtonTitle = tool.interfaceStrings.openToolDetailsActionTitle
        
        accessibilityWithToolName = AccessibilityStrings.Button.getToolButtonAccessibility(toolButton: accessibility, toolName: tool.name)
            
        getToolIsFavoritedUseCase
            .getToolIsFavoritedPublisher(toolId: tool.dataModelId)
            .map { $0.isFavorited }
            .receive(on: DispatchQueue.main)
            .assign(to: &$isFavorited)
        
        let attachmentId: String = tool.bannerImageId
        
        getToolBannerUseCase
            .execute(attachmentId:attachmentId)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] (image: Image?) in
                
                self?.banner = OptionalImageData(image: image, imageIdForAnimationChange: attachmentId)
            }
            .store(in: &cancellables)
    }
}
