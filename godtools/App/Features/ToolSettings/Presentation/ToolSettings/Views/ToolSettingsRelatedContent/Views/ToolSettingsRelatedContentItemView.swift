//
//  ToolSettingsRelatedContentItemView.swift
//  ToolSettings
//
//  Created by Levi Eggert on 5/10/22.
//

import SwiftUI

struct ToolSettingsRelatedContentItemView: View {
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 0) {
                Spacer()
                Text("Title Goes Here")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
        }
        .frame(width: 112, height: 112)
        .background(Color.gray)
    }
}

struct ToolSettingsRelatedContentItemView_Preview: PreviewProvider {
    static var previews: some View {
        ToolSettingsRelatedContentItemView()
    }
}
