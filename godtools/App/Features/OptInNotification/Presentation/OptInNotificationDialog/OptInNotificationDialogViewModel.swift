//
//  NotificationPermissionDialog.swift
//  godtools
//
//  Created by Jason Bennett on 3/27/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Combine
import Foundation
import UIKit

class OptInNotificationDialogViewModel: AlertMessageViewModelType {

    private let viewOptInDialogDomainModel: ViewOptInDialogDomainModel
    private let userDialogReponse: PassthroughSubject<Void, Never>?

    let title: String?
    let message: String?
    let cancelTitle: String?
    let acceptTitle: String

    init(viewOptInDialogDomainModel: ViewOptInDialogDomainModel, userDialogReponse: PassthroughSubject<Void, Never>?) {
       
        self.viewOptInDialogDomainModel = viewOptInDialogDomainModel
        self.userDialogReponse = userDialogReponse

        title = viewOptInDialogDomainModel.interfaceStrings.title
        message = viewOptInDialogDomainModel.interfaceStrings.body
        cancelTitle = viewOptInDialogDomainModel.interfaceStrings.cancelActionTitle
        acceptTitle = viewOptInDialogDomainModel.interfaceStrings.settingsActionTitle
    }

    deinit {
        print("x deinit: \(type(of: self))")

        userDialogReponse?.send(Void())
    }

    func acceptTapped() {
        
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        UIApplication.shared.open(
            settingsURL, options: [:], completionHandler: nil
        )
    }
}
