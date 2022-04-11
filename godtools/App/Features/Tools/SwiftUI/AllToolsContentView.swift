//
//  AllToolsContentView.swift
//  godtools
//
//  Created by Rachael Skeath on 4/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct AllToolsContentView: View {
    init() {
        // TODO: - In iOS 14/15, remove this and use appropriate modifiers instead.
        // List is built on UITableView. For iOS 13, modifiers don't yet exist to override certain default styles on List, so we use `appearance` on UITableView instead. This changes the style system-wide, so we'll have to watch out for this causing issues in other areas.
        UITableView.appearance().separatorColor = .clear
    }
    
    // MARK: - Body
    
    var body: some View {
        List {
            // TODO: - These sections will be completed in GT-1265 & GT-1498
            Text("Spotlight")
            Text("Categories")
            
            ForEach(0..<10) { i in
                // TODO: - use real view model!
                ToolCardView(viewModel: ToolCardViewModel(getBannerImageUseCase: MockGetBannerImageUseCase(), getToolDataUseCase: MockGetToolDataUseCase()))
            }
        }
        .frame(maxWidth: .infinity)
        .edgesIgnoringSafeArea([.leading, .trailing])
        .listStyle(.plain)
    }
}

// MARK: - Preview

struct AllToolsContentView_Previews: PreviewProvider {
    static var previews: some View {
        AllToolsContentView()
    }
}
