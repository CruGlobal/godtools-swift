//
//  DeleteAccountHostingView.swift
//  godtools
//
//  Created by Levi Eggert on 7/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import SwiftUI

class DeleteAccountHostingView: UIHostingController<DeleteAccountView> {
    
    private let viewModel: DeleteAccountViewModel
    
    init(view: DeleteAccountView) {
        
        self.viewModel = view.viewModel
        
        super.init(rootView: view)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = viewModel.navTitle
        
        _ = addDefaultNavBackItem(target: self, action: #selector(navigationBackButtonTapped))
    }
    
    @objc private func navigationBackButtonTapped() {

        viewModel.backTapped()
    }
}
