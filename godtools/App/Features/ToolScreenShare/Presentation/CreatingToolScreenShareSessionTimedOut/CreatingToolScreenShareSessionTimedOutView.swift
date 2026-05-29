//
//  CreatingToolScreenShareSessionTimedOutView.swift
//  godtools
//
//  Created by Levi Eggert on 11/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

final class CreatingToolScreenShareSessionTimedOutView: AlertMessageView {
    
    init(viewModel: CreatingToolScreenShareSessionTimedOutViewModel) {
                    
        super.init(
            title: viewModel.title,
            message: viewModel.message,
            acceptTitle: viewModel.acceptTitle,
            cancelTitle: viewModel.cancelTitle,
            acceptTapped: {
                viewModel.acceptTapped()
            },
            cancelTapped: {
                viewModel.cancelTapped()
            }
        )
    }
}
