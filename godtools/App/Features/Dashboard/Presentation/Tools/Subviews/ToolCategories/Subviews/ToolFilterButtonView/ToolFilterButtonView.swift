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
    
    @ObservedObject private var viewModel: ToolFilterButtonViewModel
    
    private let width: CGFloat
    private let backgroundColor: Color = Color.white
    private let cornerRadius: CGFloat = ToolFilterButtonView.height / 2
    private let tappedClosure: (() -> Void)?
        
    init(viewModel: ToolFilterButtonViewModel, width: CGFloat, tappedClosure: (() -> Void)?) {
        
        self.viewModel = viewModel
        self.width = width
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            backgroundColor
            
            Text(viewModel.title)
                .multilineTextAlignment(.leading)
                .foregroundColor(ColorPalette.gtGrey.color)
                .font(FontLibrary.sfProTextBold.font(size: 14))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding([.top, .bottom], 8)
                .padding([.leading, .trailing], 20)
            
        }
        .frame(width: width, height: ToolFilterButtonView.height)
        .cornerRadius(cornerRadius)
        .shadow(color: Color.black.opacity(0.25), radius: 4, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(Color.clear, lineWidth: 2)
        )
        .contentShape(Rectangle()) // This fixes tap area not taking entire card into account.  Noticeable in iOS 14.
        .onTapGesture {
            
            tappedClosure?()
        }
        
    }
}

// MARK: - Preview

struct ToolFilterButtonView_Previews: PreviewProvider {
        
    static var previews: some View {
        
        let viewModel = ToolFilterButtonViewModel(
            category: ToolCategoryDomainModel(type: .category(id: "1"), translatedName: "Conversation Starter")
        )
        
        ToolFilterButtonView(
            viewModel: viewModel,
            width: 40,
            tappedClosure: nil
        )
    }
}
