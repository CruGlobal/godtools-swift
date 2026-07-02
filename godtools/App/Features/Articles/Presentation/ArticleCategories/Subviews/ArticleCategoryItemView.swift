//
//  ArticleCategoryItemView.swift
//  godtools
//
//  Created by Levi Eggert on 5/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct ArticleCategoryItemView: View {
    
    private let category: ArticleCategoryDomainModel
    private let width: CGFloat
    private let tappedClosure: (() -> Void)?
    private let imageAspectRatio: CGSize = CGSize(width: 414, height: 221)
    
    init(category: ArticleCategoryDomainModel, width: CGFloat, tappedClosure: (() -> Void)?) {
        
        self.category = category
        self.width = width
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {

        ZStack(alignment: .topLeading) {
            
            OptionalImage(
                imageData: OptionalImageData(image: category.image, imageIdForAnimationChange: category.id),
                imageSize: .aspectRatio(width: width, aspectRatio: imageAspectRatio),
                contentMode: .fill,
                placeholderColor: .white
            )
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text(category.title)
                    .foregroundStyle(Color.white)
                    .font(FontLibrary.sfProTextRegular.font(size: 28))
                    .padding([.top], 22)
                    .padding([.leading], 16)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            tappedClosure?()
        }
    }
}
