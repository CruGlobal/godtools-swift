//
//  ShareGodToolsView.swift
//  godtools
//
//  Created by Levi Eggert on 4/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import UIKit

class ShareGodToolsView: UIActivityViewController {
    
    init(viewModel: ShareGodToolsViewModel) {
        
        super.init(activityItems: [viewModel.shareMessage], applicationActivities: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view didload: \(type(of: self))")
        
        addScreenAccessibility(screenAccessibility: .shareGodTools)
    }
}
