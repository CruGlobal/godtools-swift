//
//  ConfirmRemoveToolFromFavoritesAlertView.swift
//  godtools
//
//  Created by Levi Eggert on 8/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

final class ConfirmRemoveToolFromFavoritesAlertView: AlertMessageView {
    
    init(viewModel: ConfirmRemoveToolFromFavoritesAlertViewModel) {
        
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
