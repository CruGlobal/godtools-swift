//
//  MockGetBannerImageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 4/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

class MockGetBannerImageUseCase: GetBannerImageUseCase {
    
    var nilImage: Bool = false
    
    private static let bannerImageNames = ["banner1", "banner2"]
    
    init(nilImage: Bool = false) {
        self.nilImage = nilImage
    }
    
    func getBannerImage() -> Image? {
        return nilImage ? nil : Image(MockGetBannerImageUseCase.bannerImageNames.randomElement()!)
    }
}
