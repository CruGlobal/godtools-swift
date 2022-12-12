//
//  MobileContentErrorView.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentErrorView {
    
    let controller: UIAlertController
    
    init(viewModel: MobileContentErrorViewModel) {
                        
        controller = UIAlertController(
            title: viewModel.title,
            message: viewModel.message,
            preferredStyle: .alert
        )
        
        controller.addAction(UIAlertAction(title: viewModel.acceptTitle, style: .default, handler: { (action: UIAlertAction) in

        }))
    }
}
