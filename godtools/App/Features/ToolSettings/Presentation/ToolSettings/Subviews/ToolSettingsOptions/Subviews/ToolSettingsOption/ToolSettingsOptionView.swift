//
//  ToolSettingsOptionView.swift
//  godtools
//
//  Created by Levi Eggert on 5/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolSettingsOptionView: View {
        
    private let viewBackground: ToolSettingsOptionViewBackground
    private let title: String
    private let titleColorStyle: ToolSettingsOptionViewTitleColorStyle
    private let iconImage: Image
    private let accessibility: AccessibilityStrings.Button?
    private let tappedClosure: (() -> Void)?
        
    init(viewBackground: ToolSettingsOptionViewBackground, title: String, titleColorStyle: ToolSettingsOptionViewTitleColorStyle, iconImage: Image, accessibility: AccessibilityStrings.Button?, tappedClosure: (() -> Void)?) {
        
        self.viewBackground = viewBackground
        self.title = title
        self.titleColorStyle = titleColorStyle
        self.iconImage = iconImage
        self.accessibility = accessibility
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
        
        ZStack(alignment: .center) { 
        
            if let accessibilityId = accessibility?.id {
                AccessibilityTapAreaView(accessibilityIdentifier: accessibilityId)
            }
            
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
