//
//  ToolSettingsOptionsView.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/10/22.
//

import SwiftUI

struct ToolSettingsOptionsView: View {
        
    let leadingInset: CGFloat
    let trailingInset: CGFloat
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 0) {
            ScrollView (.horizontal, showsIndicators: false) {
                HStack {
                    ToolSettingsOptionsItemView()
                    ToolSettingsOptionsItemView()
                    ToolSettingsOptionsItemView()
                    ToolSettingsOptionsItemView()
                    ToolSettingsOptionsItemView()
                    ToolSettingsOptionsItemView()
                    ToolSettingsOptionsItemView()
                }
                .padding(EdgeInsets(top: 0, leading: leadingInset, bottom: 0, trailing: 0))
            }
        }
    }
}

struct ToolSettingsOptionsView_Preview: PreviewProvider {
    static var previews: some View {
        ToolSettingsOptionsView(leadingInset: 20, trailingInset: 20)
    }
}
