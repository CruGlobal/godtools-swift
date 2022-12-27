//
//  AboutView.swift
//  godtools
//
//  Created by Levi Eggert on 12/27/22.
//  Copyright © 2020 Cru. All rights reserved.
//

import SwiftUI

struct AboutView: View {
        
    @ObservedObject var viewModel: AboutViewModel
        
    var body: some View {
        
        GeometryReader { geometry in
            
            ScrollView(.vertical) {
                
                VStack(alignment: .center, spacing: 0) {
                    
                    Text(viewModel.aboutText)
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .font(FontLibrary.sfProTextRegular.font(size: 17))
                        .multilineTextAlignment(.leading)
                }
                .padding(EdgeInsets(top: 25, leading: 25, bottom: 25, trailing: 25))
            }
        }
        .onAppear {
            viewModel.pageViewed()
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(viewModel.navTitle)
    }
}
