//
//  ToolSettingsSeparator.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/10/22.
//

import SwiftUI

struct ToolSettingsSeparatorView: View {
    
    let separatorSpacing: CGFloat
    let separatorLeadingInset: CGFloat
    let separatorTrailingInset: CGFloat
    
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
        .padding(EdgeInsets(top: 0, leading: separatorLeadingInset, bottom: 0, trailing: separatorTrailingInset))
    }
}

struct ToolSettingsSeparatorView_Preview: PreviewProvider {
    static var previews: some View {
        ToolSettingsSeparatorView(separatorSpacing: 25, separatorLeadingInset: 20, separatorTrailingInset: 20)
    }
}
