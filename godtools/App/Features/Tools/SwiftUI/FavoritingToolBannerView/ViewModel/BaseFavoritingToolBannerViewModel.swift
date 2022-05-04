//
//  BaseFavoritingToolBannerViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/4/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol FavoritingToolBannerDelegate: AnyObject {
    func closeBanner()
}

class BaseFavoritingToolBannerViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    weak var delegate: FavoritingToolBannerDelegate?
    
    // MARK: - Published
    
    @Published var message: String
    
    // MARK: - Init
    
    init(message: String, delegate: FavoritingToolBannerDelegate?) {
        self.message = message
        self.delegate = delegate
    }
    
    // MARK: - Public Methods
    
    func closeTapped() {}
}
