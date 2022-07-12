//
//  ToolSettingsOptionsItemView.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/10/22.
//

import SwiftUI

struct ToolSettingsOptionsItemView: View {
        
    let backgroundType: ToolSettingsOptionItemBackgroundType
    let iconImage: Image
    let title: String
    let titleColorStyle: ToolSettingsOptionItemTitleColorStyle
    
    var body: some View {
        
        GeometryReader { geometry in
            
            if let image = backgroundType.getImage() {
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
        .background(backgroundType.getColor())
        .cornerRadius(12)
    }
}
