//
//  AlertMessageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/10/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct AlertMessageViewAcceptHandler {
    let acceptHandler: (() -> Void)
}

class AlertMessageViewModel: AlertMessageViewModelType {
    
    let title: String
    let message: String
    let acceptActionTitle: String
    let handler: AlertMessageViewAcceptHandler?
    
    required init(title: String, message: String, acceptActionTitle: String = NSLocalizedString("alert.action.ok", comment: ""), handler: AlertMessageViewAcceptHandler?) {
        
        self.title = title
        self.message = message
        self.acceptActionTitle = acceptActionTitle
        self.handler = handler
    }
    
    func acceptTapped() {
        handler?.acceptHandler()
    }
}
