//
//  ToolSpotlightView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolSpotlightView: View {
    let viewModel = MockToolCardViewModel(title: "Title", category: "Category", showParallelLanguage: false, showBannerImage: true, attachmentsDownloadProgress: 0.2, translationDownloadProgress: 0.5)
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("Tool Spotlight")
                    .font(FontLibrary.sfProTextRegular.font(size: 22))
                Text("Here are some tools we thought you might like")
                    .font(FontLibrary.sfProTextRegular.font(size: 12))
            }
            .padding(.leading, 20)
            .padding(.top, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(0..<10) { i in
                        ToolCardView(viewModel: viewModel, cardWidth: 150)
                            .padding(8)
                    }
                }
                .padding(.leading, 12)
            }
        }
    }
}

struct ToolSpotlightView_Previews: PreviewProvider {
    static var previews: some View {
        ToolSpotlightView()
    }
}
