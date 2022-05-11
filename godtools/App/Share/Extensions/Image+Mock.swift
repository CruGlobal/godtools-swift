//
//  MockBannerImage.swift
//  godtools
//
//  Created by Rachael Skeath on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

extension Image {
    
    static func mockImage(resourceId: String = "2") -> Image? {
        let appDiContainer: AppDiContainer = SwiftUIPreviewDiContainer().getAppDiContainer()
        guard let deviceImage = appDiContainer.deviceAttachmentBanners.getDeviceBanner(resourceId: resourceId) else { return nil }
        
        return Image(uiImage: deviceImage)
    }
}
