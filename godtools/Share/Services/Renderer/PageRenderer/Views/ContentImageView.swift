//
//  ContentImageView.swift
//  godtools
//
//  Created by Levi Eggert on 10/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ContentImageView: RendererNodeView {
    
    private let imageView: UIImageView = UIImageView()
    
    let viewModel: ContentImageViewModel
    
    required init(viewModel: ContentImageViewModel) {
        
        self.viewModel = viewModel
    }
    
    var contentView: UIView {
        return imageView
    }
}
