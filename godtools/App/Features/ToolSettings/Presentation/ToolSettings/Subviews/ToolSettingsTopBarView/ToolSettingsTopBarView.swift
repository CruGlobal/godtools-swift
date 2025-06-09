//
//  ToolSettingsTopBarView.swift
//  godtools
//
//  Created by Levi Eggert on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolSettingsTopBarView: View {
            
    private let title: String
    private let closeTapped: (() -> Void)?
    
    init(title: String, closeTapped: (() -> Void)? = nil) {
        
        self.title = title
        self.closeTapped = closeTapped
    }
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(ColorPalette.gtGrey.color)
                .font(FontLibrary.sfProTextRegular.font(size: 23))
            Spacer()
            Button {
                closeTapped?()
            } label: {
                Image(ImageCatalog.navClose.name)
            }
            .frame(minWidth: 44, minHeight: 44)
        }
    }
}
