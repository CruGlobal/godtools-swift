//
//  PageView.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class PageView: RendererNodeView {
    
    private let view: UIView = UIView()
    
    let viewModel: PageViewModel
    
    required init(viewModel: PageViewModel) {
        
        self.viewModel = viewModel
        
        view.frame = UIScreen.main.bounds
        view.drawBorder(color: .red)
    }
    
    var contentView: UIView {
        return view
    }
}
