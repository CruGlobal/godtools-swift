//
//  TemplateView.swift
//  godtools
//
//  Created by Levi Eggert on 8/21/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import SwiftUI

struct TemplateView: View {
    
    @ObservedObject private var viewModel: TemplateViewModel
    
    init(viewModel: TemplateViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            TemplateSubView()
        }
    }
}
