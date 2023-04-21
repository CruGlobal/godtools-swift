//
//  ArticleDebugView.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ArticleDebugView: View {
    
    @ObservedObject private var viewModel: ArticleDebugViewModel
    
    init(viewModel: ArticleDebugViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(alignment: .leading, spacing: 0) {
                
            }
        }
    }
}


