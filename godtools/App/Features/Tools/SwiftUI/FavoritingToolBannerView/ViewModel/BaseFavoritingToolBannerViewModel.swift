//
//  BaseFavoritingToolBannerViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/4/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class BaseFavoritingToolBannerViewModel: NSObject, ObservableObject {
    
    // MARK: - Published
    
    @Published var message: String
    
    // MARK: - Init
    
    init(message: String) {
        self.message = message
    }
    
    // MARK: - Public Methods
    
    func closeTapped() {}
}
