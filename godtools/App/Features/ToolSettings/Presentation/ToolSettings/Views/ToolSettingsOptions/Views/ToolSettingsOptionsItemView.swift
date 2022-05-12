//
//  ToolSettingsOptionsItemView.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/10/22.
//

import SwiftUI

struct ToolSettingsOptionsItemView: View {
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Image(ImageCatalog.toolSettingsOptionShareLink.name)
                    .frame(width: 23, height: 23)
                Text("Title Here")
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
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
        .frame(width: 94, height: 94)
        .background(Color.red)
        .cornerRadius(12)
    }
}

struct ToolSettingsOptionView_Preview: PreviewProvider {
    static var previews: some View {
        ToolSettingsOptionsItemView()
    }
}
