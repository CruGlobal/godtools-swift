//
//  ToolSettingsShareableItemView.swift
//  godtools
//
//  Created by Levi Eggert on 5/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolSettingsShareableItemView: View {
    
    private let itemSize: CGSize = CGSize(width: 112, height: 112)
    private let tappedClosure: (() -> Void)?
    
    @ObservedObject private var viewModel: ToolSettingsShareableItemViewModel
    
    init(viewModel: ToolSettingsShareableItemViewModel, tappedClosure: (() -> Void)?) {
        
        self.viewModel = viewModel
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
        
        ZStack {
            
            OptionalImage(
                imageData: viewModel.imageData,
                imageSize: .fixed(width: itemSize.width, height: itemSize.height),
                contentMode: .fit,
                placeholderColor: ColorPalette.gtLightestGrey.color
            )
            
            VStack(alignment: .center, spacing: 0) {
                
                Spacer()
                
                Text(viewModel.title)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
        }
        .frame(width: itemSize.width, height: itemSize.height)
        .onTapGesture {
            tappedClosure?()
        }
    }
}
