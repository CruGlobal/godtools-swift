//
//  ShareShareableView.swift
//  godtools
//
//  Created by Levi Eggert on 5/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class ShareShareableView: UIActivityViewController {
    
    private let viewModel: ShareShareableViewModel
    
    required init(viewModel: ShareShareableViewModel) {
        
        self.viewModel = viewModel
        
        super.init(activityItems: [viewModel.imageToShare], applicationActivities: nil)
    }
}
