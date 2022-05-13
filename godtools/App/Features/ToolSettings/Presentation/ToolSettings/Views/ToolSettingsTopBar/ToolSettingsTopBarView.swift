//
//  ToolSettingsTopBarView.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/11/22.
//

import SwiftUI

struct ToolSettingsTopBarView: View {
    
    let leadingInset: CGFloat
    let trailingInset: CGFloat
    
    var body: some View {
        HStack {
            Text("Tool Settings")
            Spacer()
            Button {
                print("tapped")
            } label: {
                Image("tool_settings_close")
            }
            .frame(minWidth: 44, minHeight: 44)
        }
        .padding(EdgeInsets(top: 0, leading: leadingInset, bottom: 0, trailing: trailingInset))
        .frame(height: 50)
    }
}

struct ToolSettingsTopBarView_Preview: PreviewProvider {
    static var previews: some View {
        ToolSettingsTopBarView(leadingInset: 20, trailingInset: 20)
    }
}
