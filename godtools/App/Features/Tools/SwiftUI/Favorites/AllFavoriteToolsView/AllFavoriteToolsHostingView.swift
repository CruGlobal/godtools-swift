//
//  AllFavoriteToolsHostingView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import SwiftUI

class AllFavoriteToolsHostingView: UIHostingController<AllFavoriteToolsView> {
    
    private let viewModel: AllFavoriteToolsViewModel
    
    init(view: AllFavoriteToolsView) {
        
        self.viewModel = view.viewModel
        
        super.init(rootView: view)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = addDefaultNavBackItem(target: self, action: #selector(navigationBackButtonTapped))
    }
    
    @objc private func navigationBackButtonTapped() {
                
        viewModel.backButtonTapped()
    }
}
