//
//  LessonsView.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import SwiftUI

class LessonsView: UIHostingController<LessonsContentView>, ToolsMenuPageView {
    
    private let contentView: LessonsContentView
    
    required init(contentView: LessonsContentView) {
        
        self.contentView = contentView
        
        super.init(rootView: contentView)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pageViewed() {
        contentView.viewModel.pageViewed()
    }
}
