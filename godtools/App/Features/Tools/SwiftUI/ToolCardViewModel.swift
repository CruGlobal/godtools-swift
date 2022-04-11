//
//  ToolCardViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI

class ToolCardViewModel: ObservableObject {
    
    // MARK: - Properties
    
    private let getBannerImageUseCase: GetBannerImageUseCase
    private let getToolDataUseCase: GetToolDataUseCase
    
    // MARK: - Published
    
    @Published var bannerImage: Image?
    @Published var title: String = ""
    @Published var category: String = ""
    // TODO: - figure out semantic content for SwiftUI
    @Published var toolSemanticContentAttribute: UISemanticContentAttribute = .forceLeftToRight
    
    init(getBannerImageUseCase: GetBannerImageUseCase, getToolDataUseCase: GetToolDataUseCase) {
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getToolDataUseCase = getToolDataUseCase
        
        bannerImage = getBannerImageUseCase.getBannerImage()
        
        let toolData = getToolDataUseCase.getToolData()
        title = toolData.title
        category = toolData.category
        toolSemanticContentAttribute = toolData.semanticContentAttribute
        
        // TODO: - figure out where binding to observers should happen (like listening for language change.  In a use case?  Here?
    }
}
