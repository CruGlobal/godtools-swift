//
//  AlertMessageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/10/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AlertMessageViewModel: AlertMessageViewModelType {
    
    let title: String?
    let message: String?
    let cancelTitle: String?
    let acceptTitle: String
    let acceptHandler: CallbackHandler?
    
    init(title: String?, message: String?, cancelTitle: String?, acceptTitle: String, acceptHandler: CallbackHandler?) {
        
        self.title = title
        self.message = message
        self.cancelTitle = cancelTitle
        self.acceptTitle = acceptTitle
        self.acceptHandler = acceptHandler
    }
    
    func acceptTapped() {
        acceptHandler?.handle()
    }
}
