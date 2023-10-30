//
//  DownloadToolProgressView.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct DownloadToolProgressView: View {
    
    @ObservedObject private var viewModel: DownloadToolProgressViewModel
    
    init(viewModel: DownloadToolProgressViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        FullScreenDownloadProgressView(
            downloadMessage: viewModel.message,
            downloadProgress: viewModel.downloadProgress,
            downloadProgressString: viewModel.downloadProgressString
        )
    }
    
    func completeDownloadProgress(completion: @escaping (() -> Void)) {
        viewModel.completeDownloadProgress(didCompleteProgress: completion)
    }
}
