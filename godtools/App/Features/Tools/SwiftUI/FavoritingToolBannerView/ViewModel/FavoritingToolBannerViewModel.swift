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

class FavoritingToolBannerViewModel: BaseFavoritingToolBannerViewModel {
    
    // MARK: - Properties
    
    private weak var delegate: FavoritingToolBannerDelegate?
    private let localizationServices: LocalizationServices
    
    // MARK: - Init
    
    init(localizationServices: LocalizationServices, delegate: FavoritingToolBannerDelegate) {
        self.localizationServices = localizationServices
        self.delegate = delegate
        
        let message = localizationServices.stringForMainBundle(key: "tool_offline_favorite_message")
        
        super.init(message: message)
    }
    
    // MARK: - Public
    
    override func closeTapped() {
        delegate?.closeBanner()
    }
}
