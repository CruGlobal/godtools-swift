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
        
        TextWithLinks(
            text: viewModel.aboutDetails,
            textColor: ColorPalette.primaryTextColor.uiColor,
            font: FontLibrary.sfProTextRegular.uiFont(size: 16),
            lineSpacing: 3,
            width: width,
            didInteractWithUrlClosure: { (url: URL) in
                viewModel.urlTapped(url: url)
            }
        )
    }
}
