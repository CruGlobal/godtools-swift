//
//  AlertMessageView.swift
//  godtools
//
//  Created by Levi Eggert on 2/10/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class AlertMessageView {
    
    let controller: UIAlertController
    
    required init(viewModel: AlertMessageViewModelType) {
                        
        controller = UIAlertController(
            title: viewModel.title,
            message: viewModel.message,
            preferredStyle: .alert
        )
        
        controller.addAction(UIAlertAction(title: viewModel.acceptActionTitle, style: .default, handler: { (action: UIAlertAction) in
            viewModel.acceptTapped()
        }))
    }
}
