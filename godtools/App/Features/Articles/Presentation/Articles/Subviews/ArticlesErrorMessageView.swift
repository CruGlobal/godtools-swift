//
//  ArticlesErrorMessageView.swift
//  godtools
//
//  Created by Levi Eggert on 6/3/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct ArticlesErrorMessageView: View {
    
    private let geometry: GeometryProxy
    private let horizontalPadding: CGFloat
    private let error: ArticlesErrorDomainModel
    private let actionTapped: (() -> Void)?
    
    init(
        geometry: GeometryProxy,
        horizontalPadding: CGFloat,
        error: ArticlesErrorDomainModel,
        actionTapped: (() -> Void)?
    ) {
        
        self.geometry = geometry
        self.horizontalPadding = horizontalPadding
        self.error = error
        self.actionTapped = actionTapped
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Text(error.title)
                .foregroundColor(Color.black)
                .font(FontLibrary.sfProTextSemibold.font(size: 18))
            
            Text(error.message)
                .foregroundColor(Color.black)
                .font(FontLibrary.sfProTextRegular.font(size: 18))
                .padding([.top], 8)
            
            CustomButton(
                attributes: CustomButtonAttributes(
                    width: geometry.size.width - (horizontalPadding * 2),
                    height: 50,
                    color: ColorPalette.gtBlue.color
                ),
                accessibilityId: nil,
                highlightContent: {
                    
                },
                nonHighlightContent: {
                    Text(error.downloadActionTitle)
                        .foregroundColor(Color.white)
                        .font(Font.system(size: 18))
                },
                tappedClosure: {
                    actionTapped?()
                }
            )
            .padding([.top], 50)
        }
        .padding([.horizontal], horizontalPadding)
    }
}
