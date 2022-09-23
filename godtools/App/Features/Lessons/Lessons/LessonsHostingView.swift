//
//  LessonsHostingView.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import SwiftUI

class LessonsHostingView: UIHostingController<LessonsView>, ToolsMenuPageView {
    
    private let contentView: LessonsView
    
    required init(contentView: LessonsView) {
        
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
