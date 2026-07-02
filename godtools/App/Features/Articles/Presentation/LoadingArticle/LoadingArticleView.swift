//
//  LoadingArticleView.swift
//  godtools
//
//  Created by Levi Eggert on 7/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct LoadingArticleView: View {

    @ObservedObject private var viewModel: LoadingArticleViewModel
    
    init(viewModel: LoadingArticleViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            FullScreenDownloadProgressView(
                downloadMessage: viewModel.message
            )
        }
    }
}
