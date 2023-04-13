//
//  ToolDetailsSectionDescriptionTextView.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ToolDetailsSectionDescriptionTextView: View {
        
    private let geometry: GeometryProxy
    private let text: String
    
    @ObservedObject private var viewModel: ToolDetailsViewModel
    
    init(viewModel: ToolDetailsViewModel, geometry: GeometryProxy, text: String) {
        
        self.viewModel = viewModel
        self.geometry = geometry
        self.text = text
    }
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 0) {
           
            TextWithLinks(
                text: text,
                textColor: ColorPalette.gtGrey.uiColor,
                font: FontLibrary.sfProTextRegular.uiFont(size: 16),
                lineSpacing: 3,
                width: geometry.size.width - ToolDetailsView.sectionDescriptionTextInsets.leading - ToolDetailsView.sectionDescriptionTextInsets.trailing,
                adjustsFontForContentSizeCategory: true,
                didInteractWithUrlClosure: { (url: URL) in
                    viewModel.urlTapped(url: url)
                    return true
                }
            )
        }
        .padding(ToolDetailsView.sectionDescriptionTextInsets)
    }
}
