//
//  ToolSettingsSeparator.swift
//  godtools
//
//  Created by Levi Eggert on 5/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolSettingsSeparatorView: View {
    
    private let separatorSpacing: CGFloat
    
    init(separatorSpacing: CGFloat) {
        
        self.separatorSpacing = separatorSpacing
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .frame(maxWidth: .infinity, minHeight: separatorSpacing, maxHeight: separatorSpacing)
                .foregroundColor(.clear)
            Rectangle()
                .foregroundColor(Color(.sRGB, red: 226 / 256, green: 226 / 256, blue: 226 / 256, opacity: 1))
                .frame(maxWidth: .infinity, maxHeight: 1)
            Rectangle()
                .frame(maxWidth: .infinity, minHeight: separatorSpacing, maxHeight: separatorSpacing)
                .foregroundColor(.clear)
        }
    }
}
