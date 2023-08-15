//
//  LessonsHeaderView.swift
//  godtools
//
//  Created by Levi Eggert on 8/14/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct LessonsHeaderView: View {
    
    @ObservedObject private var viewModel: LessonsViewModel
        
    init(viewModel: LessonsViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text(viewModel.sectionTitle)
                .font(FontLibrary.sfProTextRegular.font(size: 22))
                .foregroundColor(ColorPalette.gtGrey.color)
            
            FixedVerticalSpacer(height: 5)
            
            Text(viewModel.subtitle)
                .font(FontLibrary.sfProTextRegular.font(size: 14))
                .foregroundColor(ColorPalette.gtGrey.color)
        }
    }
}

