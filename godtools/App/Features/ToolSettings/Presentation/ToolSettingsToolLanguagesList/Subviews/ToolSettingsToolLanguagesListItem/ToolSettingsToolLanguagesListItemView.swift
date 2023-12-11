//
//  ToolSettingsToolLanguagesListItemView.swift
//  godtools
//
//  Created by Levi Eggert on 12/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ToolSettingsToolLanguagesListItemView: View {
    
    private let highlightColor: Color = Color(.sRGB, red: 209 / 256, green: 238 / 256, blue: 213 / 256, opacity: 1)
    private let verticalSpacing: CGFloat = 15
    private let tappedClosure: (() -> Void)?
    private let isSelected: Bool = false
    
    @ObservedObject private var viewModel: ToolSettingsToolLanguagesListItemViewModel
    
    init(viewModel: ToolSettingsToolLanguagesListItemViewModel, tappedClosure: (() -> Void)?) {
        
        self.viewModel = viewModel
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .frame(maxWidth: .infinity, minHeight: verticalSpacing, maxHeight: verticalSpacing)
                .foregroundColor(.clear)
            Text(viewModel.name)
                .foregroundColor(Color.black)
                .font(FontLibrary.sfProTextRegular.font(size: 15))
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            Rectangle()
                .frame(maxWidth: .infinity, minHeight: verticalSpacing, maxHeight: verticalSpacing)
                .foregroundColor(.clear)
            Rectangle()
                .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
                .foregroundColor(Color(.sRGB, red: 226 / 256, green: 226 / 256, blue: 226 / 256, opacity: 1))
        }
        .background(isSelected ? highlightColor : Color.white)
        .onTapGesture {
            tappedClosure?()
        }
    }
}
