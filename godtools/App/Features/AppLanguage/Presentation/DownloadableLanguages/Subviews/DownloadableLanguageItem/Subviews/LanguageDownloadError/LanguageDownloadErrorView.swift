//
//  LanguageDownloadErrorView.swift
//  godtools
//
//  Created by Levi Eggert on 6/26/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct LanguageDownloadErrorView: View {
    
    private let errorLabel: String
    private let actionTitle: String
    private let tappedClosure: (() -> Void)?
    
    init(errorLabel: String, actionTitle: String, tappedClosure: (() -> Void)? = nil) {
        
        self.errorLabel = errorLabel
        self.actionTitle = actionTitle
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 0) {
            
            Text(errorLabel)
                .font(FontLibrary.sfProTextRegular.font(size: 15))
                .foregroundColor(ColorPalette.gtError.color)
            
            GTButton(
                style: .error,
                title: actionTitle,
                font: FontLibrary.sfProTextSemibold.font(size: 14),
                titleHorizontalPadding: 10,
                titleVerticalPadding: 10,
                tapped: tappedClosure
            )
            .padding([.leading], 15)
        }
    }
}
