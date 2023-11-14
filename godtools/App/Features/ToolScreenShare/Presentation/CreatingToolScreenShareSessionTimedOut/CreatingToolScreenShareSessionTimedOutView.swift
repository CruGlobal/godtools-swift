//
//  CreatingToolScreenShareSessionTimedOutView.swift
//  godtools
//
//  Created by Levi Eggert on 11/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

class CreatingToolScreenShareSessionTimedOutView: AlertMessageView {
    
    init(viewModel: CreatingToolScreenShareSessionTimedOutViewModel) {
            
        super.init(viewModel: viewModel)
    }
    
    required init(viewModel: AlertMessageViewModelType) {
        fatalError("use init(viewModel: CreatingToolScreenShareSessionTimedOutViewModel)")
    }
}
