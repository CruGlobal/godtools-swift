//
//  ShareShareableViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class ShareShareableViewModel {
    
    private let shareable: Shareable
    
    let imageToShare: UIImage
    
    init(shareable: Shareable, imageToShare: UIImage) {
        
        self.shareable = shareable
        self.imageToShare = imageToShare
    }
}
