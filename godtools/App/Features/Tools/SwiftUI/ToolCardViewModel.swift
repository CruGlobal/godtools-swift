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
    
    // MARK: - Published
    
    @Published var bannerImage: Image?
    
    init(getBannerImageUseCase: GetBannerImageUseCase) {
        self.getBannerImageUseCase = getBannerImageUseCase
        
        bannerImage = getBannerImageUseCase.getBannerImage()
    }
}
