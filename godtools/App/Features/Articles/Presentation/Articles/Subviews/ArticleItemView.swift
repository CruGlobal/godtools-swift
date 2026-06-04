//
//  ArticleItemView.swift
//  godtools
//
//  Created by Levi Eggert on 6/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct ArticleItemView: View {
    
    private static let horizontalPadding: CGFloat = 25
    private static let height: CGFloat = 70
    
    private let article: ArticleListItemDomainModel
    private let tappedClosure: (() -> Void)?
    
    init(article: ArticleListItemDomainModel, tappedClosure: (() -> Void)?) {
        
        self.article = article
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            VStack(alignment: .leading, spacing: 0) {
             
                Text(article.title)
                    .foregroundColor(ColorPalette.gtBlue.color)
                    .font(Font.system(size: 18, weight: .medium))
            }
            .padding([.horizontal], Self.horizontalPadding)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: Self.height)
        .contentShape(Rectangle())
        .onTapGesture {
            tappedClosure?()
        }
    }
}
