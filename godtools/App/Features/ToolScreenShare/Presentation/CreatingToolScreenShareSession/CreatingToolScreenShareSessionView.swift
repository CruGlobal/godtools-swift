//
//  CreatingToolScreenShareSessionView.swift
//  godtools
//
//  Created by Levi Eggert on 11/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct CreatingToolScreenShareSessionView: View {
    
    @ObservedObject private var viewModel: CreatingToolScreenShareSessionViewModel
    
    init(viewModel: CreatingToolScreenShareSessionViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        FullScreenDownloadProgressView(
            downloadMessage: viewModel.creatingSessionMessage,
            hidesSpinner: false,
            downloadProgress: nil,
            downloadProgressString: nil
        )
        .onAppear {
            viewModel.pageViewed()
        }
    }
}
