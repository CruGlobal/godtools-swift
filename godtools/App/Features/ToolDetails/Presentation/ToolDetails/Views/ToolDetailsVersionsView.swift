//
//  ToolDetailsVersionsView.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolDetailsVersionsView: View {
        
    @ObservedObject var viewModel: ToolDetailsViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            ForEach(viewModel.toolVersions) { toolVersion in
                                
                ToolDetailsVersionsCardView(
                    viewModel: viewModel.getToolVersionCarViewModel(toolVersion: toolVersion)
                )
            }
        }
    }
}
