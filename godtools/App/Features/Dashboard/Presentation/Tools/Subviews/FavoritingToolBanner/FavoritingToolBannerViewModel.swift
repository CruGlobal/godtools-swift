//
//  FavoritingToolBannerViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol FavoritingToolBannerViewModelDelegate: AnyObject {
    func closeBanner()
}

class FavoritingToolBannerViewModel: ObservableObject {
        
    private let localizationServices: LocalizationServices
    
    private weak var delegate: FavoritingToolBannerViewModelDelegate?
        
    @Published var message: String
        
    init(localizationServices: LocalizationServices, delegate: FavoritingToolBannerViewModelDelegate?) {
        self.localizationServices = localizationServices
        self.delegate = delegate
        message = localizationServices.stringForMainBundle(key: "tool_offline_favorite_message")        
    }
}

// MARK: - Public

extension FavoritingToolBannerViewModel {
    
    func closeTapped() {
        delegate?.closeBanner()
    }
}
