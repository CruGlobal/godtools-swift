//
//  ToolFilterButtonView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolFilterButtonView: View {
        
    private static let height: CGFloat = 37
    
    private let buttonTitle: String
    private let width: CGFloat
    private let backgroundColor: Color = Color.white
    private let cornerRadius: CGFloat = ToolFilterButtonView.height / 2
    private let tappedClosure: (() -> Void)?
        
    init(title: String, width: CGFloat, tappedClosure: (() -> Void)?) {
        
        self.buttonTitle = title
        self.width = width
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
        
        Button {
            
            tappedClosure?()
            
        } label: {
            
            ZStack(alignment: .center) {
                                
                Rectangle()
                    .fill(.clear)
                    .frame(height: ToolFilterButtonView.height)
                    .cornerRadius(cornerRadius)
                    .ignoresSafeArea()
                
                HStack(alignment: .top) {
                    Text(buttonTitle)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .font(FontLibrary.sfProTextBold.font(size: 14))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    
                    ImageCatalog.toolFilterArrow.image
                        .padding(.top, 3)
                }
                .padding(.leading, 20)
                .padding(.trailing, 10)
                .padding(.top, 10)
                
            }
        }
        .frame(width: width, height: ToolFilterButtonView.height)
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
        .shadow(color: Color.black.opacity(0.25), radius: 3, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(Color.clear, lineWidth: 2)
        )
        .contentShape(Rectangle()) // This fixes tap area not taking entire card into account.  Noticeable in iOS 14.  
    }
}

// MARK: - Preview

struct ToolFilterButtonView_Previews: PreviewProvider {
        
    static var previews: some View {
        
        ToolFilterButtonView(
            title: "Button Title",
            width: 40,
            tappedClosure: nil
        )
    }
}
