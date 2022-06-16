//
//  ReviewShareShareableViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class ReviewShareShareableViewModel: ObservableObject {
    
    private let imageToShare: UIImage
    
    init(imageToShare: UIImage) {
        
        self.imageToShare = imageToShare
    }
}
