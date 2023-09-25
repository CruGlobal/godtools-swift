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
                .font(FontLibrary.sfProTextRegular.font(size: 24))
                .foregroundColor(ColorPalette.gtGrey.color)
                        
            Text(viewModel.subtitle)
                .font(FontLibrary.sfProTextRegular.font(size: 14))
                .foregroundColor(ColorPalette.gtGrey.color)
                .padding([.top], 7)
        }
    }
}

// MARK: - Preview

struct LessonsHeaderView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        LessonsHeaderView(
            viewModel: LessonsView_Preview.getLessonsViewModel()
        )
    }
}
