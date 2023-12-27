//
//  ToolSettingsLanguageDropDownView.swift
//  godtools
//
//  Created by Levi Eggert on 5/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolSettingsLanguageDropDownView: View {
            
    let title: String
    
    var body: some View {
       
        HStack(alignment: .center, spacing: 6) {
            Text(title)
                .foregroundColor(ColorPalette.gtGrey.color)
                .font(FontLibrary.sfProTextRegular.font(size: 16))
            Image(ImageCatalog.toolSettingsLanguageDropDownArrow.name)
                .frame(width: 10, height: 5)
        }
        .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity, minHeight: nil, idealHeight: nil, maxHeight: .infinity, alignment: .center)
    }
}
