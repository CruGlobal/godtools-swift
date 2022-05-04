//
//  FavoritingToolBannerViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol FavoritingToolBannerDelegate: AnyObject {
    
    func closeBanner()
}

class FavoritingToolBannerViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    private let localizationServices: LocalizationServices
    weak private var delegate: FavoritingToolBannerDelegate?
    
    // MARK: - Published
    
    @Published var message: String
    
    // MARK: - Init
    
    init(favoritingToolMessageCache: FavoritingToolMessageCache, localizationServices: LocalizationServices, delegate: FavoritingToolBannerDelegate?) {
        self.localizationServices = localizationServices
        self.delegate = delegate
        
        message = localizationServices.stringForMainBundle(key: "tool_offline_favorite_message")
    }
    
    // MARK: - Public
    
    func closeTapped() {
        delegate?.closeBanner()
    }
}
