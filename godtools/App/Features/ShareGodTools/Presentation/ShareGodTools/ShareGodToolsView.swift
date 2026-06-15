//
//  ShareGodToolsView.swift
//  godtools
//
//  Created by Levi Eggert on 4/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import UIKit

class ShareGodToolsView: UIActivityViewController {
    
    private let viewModel: ShareGodToolsViewModel
    
    init(viewModel: ShareGodToolsViewModel) {
        
        self.viewModel = viewModel
        
        super.init(activityItems: [viewModel.shareMessage], applicationActivities: nil)
        
        completionWithItemsHandler = { (
            activityType: UIActivity.ActivityType?,
            serviceCompleted: Bool,
            returnedItems: [Any]?,
            activityError: Error?
        ) in
            
            viewModel.activityViewDismissed()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view didload: \(type(of: self))")
        
        addScreenAccessibility(screenAccessibility: .shareGodTools)
    }
}
