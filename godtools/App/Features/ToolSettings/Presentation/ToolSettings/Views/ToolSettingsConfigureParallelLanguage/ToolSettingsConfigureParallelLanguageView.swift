//
//  ToolSettingsConfigureParallelLanguageView.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/10/22.
//

import SwiftUI

struct ToolSettingsConfigureParallelLanguageView: View {
    
    private let languageDropDownHeight: CGFloat = 52
    
    let geometryProxy: GeometryProxy
    let leadingInset: CGFloat
    let trailingInset: CGFloat
    
    @State private var vibrateOnRing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center, spacing: 0) {
                VStack (alignment: .leading, spacing: 4) {
                    Text("Parallel Language")
                    Text("Toggle between the two different languages in this tool.")
                }
                .frame(width: geometryProxy.size.width * 0.65)
                .padding(EdgeInsets(top: 0, leading: leadingInset, bottom: 0, trailing: 0))
                Toggle("", isOn: $vibrateOnRing)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: trailingInset))
            }
            HStack(alignment: .top, spacing: 0) {
                ToolSettingsLanguageDropDownView()
                Rectangle()
                    .foregroundColor(Color.black)
                    .frame(width: 44)
                ToolSettingsLanguageDropDownView()
            }
            .background(Color(.sRGB, red: 245 / 256, green: 245 / 256, blue: 245 / 256, opacity: 1))
            .cornerRadius(6)
            .frame(
                minWidth: nil,
                idealWidth: nil,
                maxWidth: .infinity,
                minHeight: languageDropDownHeight,
                idealHeight: nil,
                maxHeight: languageDropDownHeight,
                alignment: .leading
            )
            .padding(EdgeInsets(top: 0, leading: leadingInset, bottom: 0, trailing: trailingInset))
        }
    }
}

struct ToolSettingsConfigureParallelLanguageView_Preview: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            ToolSettingsConfigureParallelLanguageView(geometryProxy: geometry, leadingInset: 20, trailingInset: 20)
        }
    }
}
