//
//  ToolCardViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI

class ToolCardViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    private let resourceId: String
    
    // UseCases
    private let getBannerImageUseCase: GetBannerImageUseCase
    private let getToolDataUseCase: GetToolDataUseCase
    
    // Services
    private let favoritedResourcesCache: FavoritedResourcesCache
    
    // MARK: - Published
    
    @Published var bannerImage: Image?
    @Published var isFavorited = false
    @Published var title: String = ""
    @Published var category: String = ""
    // TODO: - figure out semantic content for SwiftUI
    @Published var toolSemanticContentAttribute: UISemanticContentAttribute = .forceLeftToRight
    
    // MARK: - Init
    
    init(resourceId: String, getBannerImageUseCase: GetBannerImageUseCase, getToolDataUseCase: GetToolDataUseCase, favoritedResourcesCache: FavoritedResourcesCache) {
        
        self.resourceId = resourceId
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getToolDataUseCase = getToolDataUseCase
        self.favoritedResourcesCache = favoritedResourcesCache
        
        bannerImage = getBannerImageUseCase.getBannerImage()
        isFavorited = favoritedResourcesCache.isFavorited(resourceId: resourceId)

        let toolData = getToolDataUseCase.getToolData()
        title = toolData.title
        category = toolData.category
        toolSemanticContentAttribute = toolData.semanticContentAttribute
                
        super.init()
        
        setupBinding()
    }
    
    deinit {
        favoritedResourcesCache.resourceFavorited.removeObserver(self)
        favoritedResourcesCache.resourceUnfavorited.removeObserver(self)
    }
    
    // MARK: - Public
    
    func favoritedButtonTapped() {
        favoritedResourcesCache.toggleFavorited(resourceId: resourceId)
    }
    
    // MARK: - Private
    
    private func setupBinding() {
        favoritedResourcesCache.resourceFavorited.addObserver(self) { [weak self] (resourceId: String) in
            guard let self = self else { return }

            if resourceId == self.resourceId {
                DispatchQueue.main.async { [weak self] in
                    self?.isFavorited = true
                }
            }
        }

        favoritedResourcesCache.resourceUnfavorited.addObserver(self) { [weak self] (resourceId: String) in
            guard let self = self else { return }

            if resourceId == self.resourceId {
                DispatchQueue.main.async { [weak self] in
                    self?.isFavorited = false
                }
            }
        }
    }
}
