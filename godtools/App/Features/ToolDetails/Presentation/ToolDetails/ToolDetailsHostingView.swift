//
//  ToolDetailsHostingView.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import SwiftUI

class ToolDetailsHostingView: UIHostingController<ToolDetailsView> {
    
    private let viewModel: ToolDetailsViewModel
    
    init(view: ToolDetailsView) {
        
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
