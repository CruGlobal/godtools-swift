//
//  AlertMessageView.swift
//  godtools
//
//  Created by Levi Eggert on 2/10/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

@MainActor
class AlertMessageView {
    
    let controller: UIAlertController
    
    init(title: String, message: String, acceptTitle: String, cancelTitle: String?, acceptTapped: (() -> Void)?, cancelTapped: (() -> Void)?) {
                        
        controller = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        if let cancelTitle = cancelTitle, !cancelTitle.isEmpty {
            controller.addAction(UIAlertAction(title: cancelTitle, style: .default, handler: { (action: UIAlertAction) in
                cancelTapped?()
            }))
        }
        
        controller.addAction(UIAlertAction(title: acceptTitle, style: .default, handler: { (action: UIAlertAction) in
            acceptTapped?()
        }))
    }
}
