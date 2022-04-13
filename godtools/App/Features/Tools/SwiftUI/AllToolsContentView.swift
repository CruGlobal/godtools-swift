//
//  AllToolsContentView.swift
//  godtools
//
//  Created by Rachael Skeath on 4/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct AllToolsContentView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: AllToolsContentViewModel
    
    // MARK: - Init
    
    init(viewModel: AllToolsContentViewModel) {
        self.viewModel = viewModel
        
        // TODO: - In iOS 14/15, remove this and use appropriate modifiers instead.
        // List is built on UITableView. For iOS 13, modifiers don't yet exist to override certain default styles on List, so we use `appearance` on UITableView instead. This changes the style system-wide, so we'll have to watch out for this causing issues in other areas.
        UITableView.appearance().separatorColor = .clear
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geo in
            List {
                // TODO: - These sections will be completed in GT-1265 & GT-1498
                Text("Spotlight")
                Text("Categories")
                
                ForEach(viewModel.tools) { tool in
                    // TODO: - fix the hardcoded -40.  List is automatically padding the left, so need to figure out how to duplicate that padding on right
                    ToolCardView(viewModel: viewModel.cardViewModel(for: tool), cardWidth: geo.size.width - 40)
                }
            }
            .frame(maxWidth: .infinity)
            .edgesIgnoringSafeArea([.leading, .trailing])
            .listStyle(.plain)
        }
    }
}

// MARK: - Preview

// TODO: - Figure out how to fix this preview

//struct AllToolsContentView_Previews: PreviewProvider {
//    static let viewModel = AllToolsContentViewModel(
//        dataDownloader: MockInitialDataDownloader(),
//        deviceAttachmentBanners: DeviceAttachmentBanners(),
//        languageSettingsService: <#LanguageSettingsService#>,
//        localizationServices: <#LocalizationServices#>
//    )
//
//    static var previews: some View {
//        AllToolsContentView(viewModel: viewModel)
//    }
//}
