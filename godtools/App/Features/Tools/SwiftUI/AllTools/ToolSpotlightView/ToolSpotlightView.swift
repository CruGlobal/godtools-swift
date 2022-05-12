//
//  ToolSpotlightView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolSpotlightView: View {
    
    @ObservedObject var viewModel: BaseToolSpotlightViewModel
    let viewModel1 = MockToolCardViewModel(title: "Title", category: "Category", showParallelLanguage: true, showBannerImage: true, attachmentsDownloadProgress: 0.2, translationDownloadProgress: 0.5)
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                
                Text(viewModel.spotlightTitle)
                    .font(FontLibrary.sfProTextRegular.font(size: 22))
                Text(viewModel.spotlightSubtitle)
                    .font(FontLibrary.sfProTextRegular.font(size: 12))
            }
            .padding(.leading, 20)
            .padding(.top, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(0..<10) { i in
                        ToolCardView(viewModel: viewModel1, cardWidth: 150, isSpotlight: true)
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
        ToolSpotlightView(viewModel: BaseToolSpotlightViewModel(spotlightTitle: "Title Goes Here", spotlightSubtitle: "Subtitle goes here"))
    }
}
