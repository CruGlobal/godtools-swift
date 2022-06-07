//
//  LanguagesListItemView.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct LanguagesListItemView: View {
    
    private let verticalSpacing: CGFloat = 15
    
    @ObservedObject var viewModel: LanguagesListItemViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .frame(maxWidth: .infinity, minHeight: verticalSpacing, maxHeight: verticalSpacing)
                .foregroundColor(.clear)
            Text(viewModel.name)
                .foregroundColor(Color.black)
                .font(FontLibrary.sfProTextRegular.font(size: 15))
            Rectangle()
                .frame(maxWidth: .infinity, minHeight: verticalSpacing, maxHeight: verticalSpacing)
                .foregroundColor(.clear)
        }
        .background(Color.white)
    }
}

struct LanguagesListItemView_Preview: PreviewProvider {
    static var previews: some View {
        
        let language = ToolLanguageModel(id: "en", name: "English")
        
        LanguagesListItemView(viewModel: LanguagesListItemViewModel(language: language))
    }
}
