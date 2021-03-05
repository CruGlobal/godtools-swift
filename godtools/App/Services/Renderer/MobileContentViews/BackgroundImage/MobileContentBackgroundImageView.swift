//
//  MobileContentBackgroundImageView.swift
//  godtools
//
//  Created by Levi Eggert on 11/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentBackgroundImageView {
    
    private var viewModel: MobileContentBackgroundImageViewModel?
    private var imageView: UIImageView?
    
    private weak var parentView: UIView?
    
    required init() {
        
    }
    
    func configure(viewModel: MobileContentBackgroundImageViewModel, parentView: UIView) {
        
        // NOTE: Only issue here is if the device rotated the image wouldn't rotate because we aren't using constraints. ~Levi
        // We would have to recalculate the render position for the background image which we can do by calling viewModel.getRenderPositionForBackgroundImage
        // on the existing imageView if the backgroundImage exists.
        
        self.viewModel = viewModel
        self.imageView = viewModel.backgroundImageWillAppear(container: parentView.bounds)
        self.parentView = parentView
        
        if let imageView = imageView {
            parentView.addSubview(imageView)
        }
    }
}
