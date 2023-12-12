//
//  ToolSettingsOptionView.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/10/22.
//

import SwiftUI

struct ToolSettingsOptionView: View {
        
    private let viewBackground: ToolSettingsOptionViewBackground
    private let title: String
    private let titleColorStyle: ToolSettingsOptionViewTitleColorStyle
    private let iconImage: Image
    private let tappedClosure: (() -> Void)?
        
    init(viewBackground: ToolSettingsOptionViewBackground, title: String, titleColorStyle: ToolSettingsOptionViewTitleColorStyle, iconImage: Image, tappedClosure: (() -> Void)?) {
        
        self.viewBackground = viewBackground
        self.title = title
        self.titleColorStyle = titleColorStyle
        self.iconImage = iconImage
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
        
        ZStack(alignment: .center) { 
        
            if let image = viewBackground.getImage() {
                
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            
            VStack(alignment: .center, spacing: 10) {
                
                iconImage
                    .frame(width: 23, height: 23)
                
                Text(title)
                    .foregroundColor(titleColorStyle.getColor())
                    .font(FontLibrary.sfProTextRegular.font(size: 14))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
            }
            .frame(
                minWidth: nil,
                idealWidth: nil,
                maxWidth: .infinity,
                minHeight: nil,
                idealHeight: nil,
                maxHeight: .infinity,
                alignment: .center
            )
        }
        .frame(width: 96, height: 96)
        .background(viewBackground.getColor())
        .cornerRadius(12)
        .onTapGesture {
            tappedClosure?()
        }
    }
}
