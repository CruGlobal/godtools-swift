//
//  LearnToShareToolItemAssetContent.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import SwiftUI

enum LearnToShareToolItemAssetContent {
    
    case animation(viewModel: AnimatedViewModel)
    case image(image: Image)
    case noAsset
}
