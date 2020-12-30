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
        
        if let cancelTitle = viewModel.cancelTitle {
            controller.addAction(UIAlertAction(title: cancelTitle, style: .default, handler: { (action: UIAlertAction) in
                
            }))
        }
        
        controller.addAction(UIAlertAction(title: viewModel.acceptTitle, style: .default, handler: { (action: UIAlertAction) in
            viewModel.acceptTapped()
        }))
    }
}
