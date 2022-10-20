//
//  AllToolsView.swift
//  godtools
//
//  Created by Levi Eggert on 5/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI

class AllToolsView: UIHostingController<AllToolsContentView> {
    
    private let contentView: AllToolsContentView
    
    required init(contentView: AllToolsContentView) {
        
        self.contentView = contentView
        
        super.init(rootView: contentView)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
