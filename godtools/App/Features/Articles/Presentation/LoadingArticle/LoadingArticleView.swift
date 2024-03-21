//
//  LoadingArticleView.swift
//  godtools
//
//  Created by Levi Eggert on 7/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class LoadingArticleView: LoadingView {
    
    private let viewModel: LoadingArticleViewModel
    
    init(viewModel: LoadingArticleViewModel, navigationBar: AppNavigationBar?) {
        
        self.viewModel = viewModel
        
        super.init(navigationBar: navigationBar, message: viewModel.message)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupLayout() {
        super.setupLayout()
    }
}

