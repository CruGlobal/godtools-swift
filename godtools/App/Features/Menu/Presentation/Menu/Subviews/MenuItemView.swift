//
//  MenuItemView.swift
//  godtools
//
//  Created by Aaron Laib on 6/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct MenuItemView: View {
    
    private let imageWidth: CGFloat = 24
    private let imageAlignment: Alignment = .leading
    
    let imageAssetName: String?
    let shouldReplaceNullAssetWithEmptySpace: Bool
    let title: String
    let tappedClosure: (() -> Void)?
    
    init(imageAssetName: String?, shouldReplaceNullAssetWithEmptySpace: Bool = false, title: String, tappedClosure: (() -> Void)?) {
        
        self.imageAssetName = imageAssetName
        self.shouldReplaceNullAssetWithEmptySpace = shouldReplaceNullAssetWithEmptySpace
        self.title = title
        self.tappedClosure = tappedClosure
    }

    var body: some View {
        
        HStack(alignment: .center, spacing: 10) {
            
            if let imageAssetName = imageAssetName, !imageAssetName.isEmpty {
                
                Image(imageAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageWidth, height: imageWidth, alignment: imageAlignment)
            }
            else if shouldReplaceNullAssetWithEmptySpace {
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: imageWidth, height: imageWidth, alignment: imageAlignment)
            }
            
            Button(action: {

                tappedClosure?()
            }) {
                
                Text(title)
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .font(FontLibrary.sfProTextRegular.font(size: 16))
                    .padding(EdgeInsets(top: MenuView.itemSpacing / 2, leading: 0, bottom: MenuView.itemSpacing / 2, trailing: 0))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .disabled(tappedClosure == nil)
        }
    }
}

