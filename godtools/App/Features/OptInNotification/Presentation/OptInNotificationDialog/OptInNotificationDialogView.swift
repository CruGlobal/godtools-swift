//
//  NotificationDialogView.swift
//  godtools
//
//  Created by Jason Bennett on 3/27/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import UIKit

class OptInNotificationDialogView: AlertMessageView {
    init(viewModel: OptInNotificationDialogViewModel) {
        super.init(viewModel: viewModel)
    }

    required init(viewModel: AlertMessageViewModelType) {
        fatalError("init(viewModel:) has not been implemented")
    }
}
