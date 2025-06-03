//
//  ToolSettingsShareablesView.swift
//  godtools
//
//  Created by Levi Eggert on 5/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolSettingsShareablesView: View {
        
    @ObservedObject private var viewModel: ToolSettingsViewModel

    init(viewModel: ToolSettingsViewModel) {
        
        self.viewModel = viewModel
    }
        
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            Text(viewModel.shareablesTitle)
                .foregroundColor(ColorPalette.gtGrey.color)
                .font(FontLibrary.sfProTextRegular.font(size: 19))
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(alignment: .center, spacing: 10) {
                                        
                    ForEach(viewModel.shareables) { (shareable: ShareableDomainModel) in
                        
                        ToolSettingsShareableItemView(
                            viewModel: viewModel.getShareableItemViewModel(shareable: shareable),
                            tappedClosure: {
                                viewModel.shareableTapped(shareable: shareable)
                            }
                        )
                    }
                }
            }
        }
    }
}
