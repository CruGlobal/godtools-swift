//
//  ToolDetailsAboutView.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolDetailsAboutView: View {
           
    @ObservedObject var viewModel: ToolDetailsViewModel
    
    let width: CGFloat
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            TextWithLinks(
                text: viewModel.aboutDetails,
                textColor: ColorPalette.gtGrey.uiColor,
                font: FontLibrary.sfProTextRegular.uiFont(size: 16),
                lineSpacing: 3,
                width: width,
                didInteractWithUrlClosure: { (url: URL) in
                    viewModel.urlTapped(url: url)
                    return true
                }
            )
            
            Rectangle()
                .frame(height: 20)
                .foregroundColor(.clear)
            
            Text(viewModel.availableLanguagesTitle)
                .foregroundColor(ColorPalette.gtGrey.color)
                .font(FontLibrary.sfProTextSemibold.font(size: 17))
            
            Rectangle()
                .frame(height: 10)
                .foregroundColor(.clear)
            
            SeparatorView()
            
            Rectangle()
                .frame(height: 10)
                .foregroundColor(.clear)
            
            Text(viewModel.availableLanguagesList)
                .foregroundColor(ColorPalette.gtGrey.color)
                .font(FontLibrary.sfProTextRegular.font(size: 16))
        }
    }
}
