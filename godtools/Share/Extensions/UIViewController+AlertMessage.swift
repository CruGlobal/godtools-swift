//
//  UIViewController+AlertMessage.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentAlertMessage(alertMessage: AlertMessageType) {
        
        let viewModel = AlertMessageViewModel(
            title: alertMessage.title,
            message: alertMessage.message,
            cancelTitle: nil,
            acceptTitle: "OK",
            acceptHandler: nil
        )
        let view = AlertMessageView(viewModel: viewModel)
        
        present(view.controller, animated: true, completion: nil)
    }
}
