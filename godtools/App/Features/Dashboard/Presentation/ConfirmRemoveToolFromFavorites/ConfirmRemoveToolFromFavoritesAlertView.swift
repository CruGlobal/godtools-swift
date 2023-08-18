//
//  ConfirmRemoveToolFromFavoritesAlertView.swift
//  godtools
//
//  Created by Levi Eggert on 8/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

class ConfirmRemoveToolFromFavoritesAlertView: AlertMessageView {
    
    init(viewModel: ConfirmRemoveToolFromFavoritesAlertViewModel) {
        
        super.init(viewModel: viewModel)
    }
    
    required init(viewModel: AlertMessageViewModelType) {
        fatalError("init(viewModel:) has not been implemented")
    }
}
