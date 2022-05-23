//
//  ToolSettingsLanguageDropDownView.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/10/22.
//

import SwiftUI

struct ToolSettingsLanguageDropDownView: View {
        
    let primaryTextColor: Color
    
    let title: String
    
    var body: some View {
       
        HStack(alignment: .center, spacing: 6) {
            Text(title)
                .foregroundColor(primaryTextColor)
                .font(FontLibrary.sfProTextRegular.font(size: 16))
            Image(ImageCatalog.toolSettingsLanguageDropDownArrow.name)
                .frame(width: 10, height: 5)
        }
        .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity, minHeight: nil, idealHeight: nil, maxHeight: .infinity, alignment: .center)
    }
}

struct ToolSettingsLanguageDropDownView_Preview: PreviewProvider {
    static var previews: some View {
        ToolSettingsLanguageDropDownView(primaryTextColor: Color.black, title: "English")
    }
}
