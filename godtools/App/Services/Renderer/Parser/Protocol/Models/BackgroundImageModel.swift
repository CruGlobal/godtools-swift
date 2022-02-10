//
//  BackgroundImageModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct BackgroundImageModel: BackgroundImageModelType {
    
    let backgroundImage: String?
    let backgroundImageAlignment: MobileContentImageAlignmentType
    let backgroundImageScale: MobileContentBackgroundImageScale
}
