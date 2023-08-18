//
//  ToolCategoryButtonView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCategoryButtonView: View {
        
    private static let defaultSize: CGSize = CGSize(width: 160, height: 74)
    
    @ObservedObject private var viewModel: ToolCategoryButtonViewModel
    
    private let backgroundColor: Color = Color.white
    private let cornerRadius: CGFloat = 6
    private let selectedTitleColor: Color = ColorPalette.gtGrey.color
    private let selectedBorderColor: Color = ColorPalette.gtBlue.color
    private let indexPosition: Int
    private let size: CGSize
    private let tappedClosure: (() -> Void)?
    
    @Binding private var selectedIndex: Int
    
    init(viewModel: ToolCategoryButtonViewModel, indexPosition: Int, selectedIndex: Binding<Int>, size: CGSize = ToolCategoryButtonView.defaultSize, tappedClosure: (() -> Void)?) {
        
        self.viewModel = viewModel
        self.indexPosition = indexPosition
        self._selectedIndex = selectedIndex
        self.size = size
        self.tappedClosure = tappedClosure
    }
    
    private var isSelected: Bool {
        return indexPosition == selectedIndex
    }
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            backgroundColor
            
            Text(viewModel.title)
                .multilineTextAlignment(.leading)
                .foregroundColor(isSelected ? selectedTitleColor : Color.gray)
                .font(FontLibrary.sfProTextBold.font(size: 18))
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding([.top, .bottom], 15)
                .padding([.leading, .trailing], 20)
            
        }
        .frame(width: size.width, height: size.height)
        .cornerRadius(cornerRadius)
        .shadow(color: Color.black.opacity(0.25), radius: 4, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(isSelected ? selectedBorderColor : Color.clear, lineWidth: 2)
        )
        .contentShape(Rectangle()) // This fixes tap area not taking entire card into account.  Noticeable in iOS 14.
        .onTapGesture {
            
            tappedClosure?()
        }
        
    }
}

// MARK: - Preview

struct ToolCategoryButtonView_Previews: PreviewProvider {
    
    @State private static var selectedIndex: Int = 0
    
    static var previews: some View {
        
        let viewModel = ToolCategoryButtonViewModel(
            category: ToolCategoryDomainModel(type: .category(id: "1"), translatedName: "Conversation Starter")
        )
        
        ToolCategoryButtonView(
            viewModel: viewModel,
            indexPosition: 0,
            selectedIndex: $selectedIndex,
            tappedClosure: nil
        )
    }
}
