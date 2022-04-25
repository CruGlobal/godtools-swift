//
//  MockGetBannerImageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 4/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

class MockGetBannerImageUseCase: GetBannerImageUseCase {
    
    private let deviceAttachmentBanners: DeviceAttachmentBanners
    var nilImage: Bool = false
        
    init(deviceAttachmentBanners: DeviceAttachmentBanners, nilImage: Bool = false) {
        self.deviceAttachmentBanners = deviceAttachmentBanners
        self.nilImage = nilImage
    }
    
    func getBannerImage() -> Image? {
        if nilImage {
            return nil
        }
        else if let deviceImage = deviceAttachmentBanners.getDeviceBanner(resourceId: "1") {
            return Image(uiImage: deviceImage)
        }
        else {
            return nil
        }
    }
}
