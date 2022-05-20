//
//  Image+OptionalUIImage.swift
//  godtools
//
//  Created by Rachael Skeath on 5/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

extension Image {
    
    static func from(uiImage: UIImage?) -> Image? {
        guard let uiImage = uiImage else { return nil }
        
        return Image(uiImage: uiImage)
    }
}
