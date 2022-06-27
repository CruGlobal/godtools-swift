//
//  BannerViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol BannerViewModelDelegate: AnyObject {
    func closeBanner()
}

class BannerViewModel: NSObject, ObservableObject {
    
    weak var delegate: BannerViewModelDelegate?
    
    // MARK: - Init
    
    init(delegate: BannerViewModelDelegate?) {
        self.delegate = delegate
    }
    
    // MARK: - Public
    
    func closeTapped() {
        delegate?.closeBanner()
    }
}
