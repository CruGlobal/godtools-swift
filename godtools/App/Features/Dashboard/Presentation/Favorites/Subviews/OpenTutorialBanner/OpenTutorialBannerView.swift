//
//  OpenTutorialBannerView.swift
//  godtools
//
//  Created by Rachael Skeath on 6/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct OpenTutorialBannerView: View {
        
    private let closeTappedClosure: (() -> Void)?
    private let openTutorialTappedClosure: (() -> Void)?
    
    @ObservedObject private var viewModel: FavoritesViewModel
    
    init(viewModel: FavoritesViewModel, closeTappedClosure: (() -> Void)?, openTutorialTappedClosure: (() -> Void)?) {
        
        self.viewModel = viewModel
        self.closeTappedClosure = closeTappedClosure
        self.openTutorialTappedClosure = openTutorialTappedClosure
    }
    
    var body: some View {
        
        BannerView {
            
            VStack {
                
                Text(viewModel.openTutorialBannerMessage)
                    .modifier(BannerTextStyle())
                
                HStack(alignment: .center) {
                    
                    Text(viewModel.openTutorialBannerButtonTitle)
                        .foregroundColor(ColorPalette.gtBlue.color)
                        .font(FontLibrary.sfProTextRegular.font(size: 17))
                        .onTapGesture {
                            openTutorialTappedClosure?()
                    }
                    
                    Image(ImageCatalog.openTutorialArrow.name)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 9, height: 17)
                        .clipped()
                }
            }
            
        } closeButtonTapHandler: {
            closeTappedClosure?()
        }
    }
}
