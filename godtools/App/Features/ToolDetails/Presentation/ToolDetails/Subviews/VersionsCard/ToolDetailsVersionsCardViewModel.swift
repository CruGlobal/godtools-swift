//
//  ToolDetailsVersionsCardViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class ToolDetailsVersionsCardViewModel: ObservableObject {
    
    private let getBannerImageUseCase: GetBannerImageUseCase
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var bannerImage: Image?
    
    let isSelected: Bool
    let name: String
    let description: String
    let languages: String
    let primaryLanguageName: String?
    let primaryLanguageIsSupported: Bool
    let parallelLanguageName: String?
    let parallelLanguageIsSupported: Bool
    
    init(toolVersion: ToolVersionDomainModel, getBannerImageUseCase: GetBannerImageUseCase, isSelected: Bool) {
        
        self.getBannerImageUseCase = getBannerImageUseCase
        self.isSelected = isSelected
        
        name = toolVersion.name
        description = toolVersion.description
        languages = toolVersion.numberOfLanguagesString
        primaryLanguageName = toolVersion.primaryLanguage
        primaryLanguageIsSupported = toolVersion.primaryLanguageIsSupported
        parallelLanguageName = toolVersion.parallelLanguage
        parallelLanguageIsSupported = toolVersion.parallelLanguageIsSupported
        
        getBannerImageUseCase.getBannerImagePublisher(for: toolVersion.bannerImageId)
            .receive(on: DispatchQueue.main)
            .assign(to: \.bannerImage, on: self)
            .store(in: &cancellables)
    }
}
