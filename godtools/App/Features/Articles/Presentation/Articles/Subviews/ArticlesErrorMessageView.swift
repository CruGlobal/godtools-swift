//
//  ArticlesErrorMessageView.swift
//  godtools
//
//  Created by Levi Eggert on 6/3/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct ArticlesErrorMessageView: View {
    
    private let title: String
    private let message: String
    private let actionTitle: String
    private let actionTapped: (() -> Void)?
    
    init(
        title: String,
        message: String,
        actionTitle: String,
        actionTapped: (() -> Void)?
    ) {
        
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.actionTapped = actionTapped
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Text(title)
                .foregroundColor(Color.black)
                .font(FontLibrary.sfProTextSemibold.font(size: 18))
            
            Text(message)
                .foregroundColor(Color.black)
                .font(FontLibrary.sfProTextRegular.font(size: 18))
                .padding([.top], 8)
            
            CustomButton(
                attributes: CustomButtonAttributes(
                    height: 50,
                    color: ColorPalette.gtBlue.color
                ),
                accessibilityId: nil,
                highlightContent: {
                    
                },
                nonHighlightContent: {
                    Text(actionTitle)
                        .foregroundColor(Color.white)
                        .font(Font.system(size: 18))
                },
                tappedClosure: {
                    actionTapped?()
                }
            )
            .padding([.top], 50)
        }
    }
}
