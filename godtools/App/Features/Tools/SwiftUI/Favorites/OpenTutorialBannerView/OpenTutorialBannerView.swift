//
//  OpenTutorialBannerView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct OpenTutorialBannerView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: OpenTutorialBannerViewModel
    
    // MARK: - Body
    
    var body: some View {
        
        BannerView {
            VStack {
                Text("Show Me A Tutorial")
                    .modifier(BannerTextStyle())
                
                Text("Open Tutorial")
                    .foregroundColor(ColorPalette.gtBlue.color)
                    .font(FontLibrary.sfProTextRegular.font(size: 17))
                    .onTapGesture {
                        viewModel.openTutorialButtonTapped()
                    }
            }
            
        } closeButtonTapHandler: {
            viewModel.closeButtonTapped()
        }
    }
}

struct OpenTutorialBannerView_Previews: PreviewProvider {
    static var previews: some View {
        
        let viewModel = OpenTutorialBannerViewModel()
        
        OpenTutorialBannerView(viewModel: viewModel)
    }
}
