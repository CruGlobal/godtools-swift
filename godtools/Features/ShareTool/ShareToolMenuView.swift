//
//  ShareToolMenuView.swift
//  godtools
//
//  Created by Levi Eggert on 8/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ShareToolMenuView {
    
    let controller: UIAlertController
    
    required init(viewModel: ShareToolMenuViewModelType) {
                        
        controller = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        controller.addAction(UIAlertAction(title: viewModel.shareToolTitle, style: .default, handler: { (action: UIAlertAction) in
            
            viewModel.shareToolTapped()
        }))
        
        controller.addAction(UIAlertAction(title: viewModel.remoteShareToolTitle, style: .default, handler: { (action: UIAlertAction) in

        }))
        
        controller.addAction(UIAlertAction(title: viewModel.cancelTitle, style: .cancel, handler: { (action: UIAlertAction) in

        }))
    }
}
