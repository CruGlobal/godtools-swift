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
            
            AccordionView(title: viewModel.availableLanguagesTitle, contents: viewModel.availableLanguagesList)
        }
    }
}
