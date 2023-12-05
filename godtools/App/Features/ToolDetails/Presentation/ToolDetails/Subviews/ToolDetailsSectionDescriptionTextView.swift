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
    private let textColor: ColorPalette = ColorPalette.gtGrey
    private let textFont: FontLibrary = FontLibrary.sfProTextRegular
    private let fontSize: CGFloat = 16
    private let lineSpacing: CGFloat = 3
    
    @ObservedObject private var viewModel: ToolDetailsViewModel
    
    init(viewModel: ToolDetailsViewModel, geometry: GeometryProxy, text: String) {
        
        self.viewModel = viewModel
        self.geometry = geometry
        self.text = text
    }
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 0) {
           
            BackwardsCompatibleTextWithLinks(
                geometry: geometry,
                text: text,
                textColor: textColor,
                textFont: textFont,
                fontSize: fontSize,
                lineSpacing: lineSpacing,
                urlTappedClosure: { (url: URL) in
                    
                    viewModel.urlTapped(url: url)
                }
            )
        }
        .padding(ToolDetailsView.sectionDescriptionTextInsets)
    }
}
