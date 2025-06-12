//
//  AccountUserDetailsView.swift
//  godtools
//
//  Created by Levi Eggert on 11/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct AccountUserDetailsView: View {
    
    @ObservedObject private var viewModel: AccountViewModel
    
    init(viewModel: AccountViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 0) {
            
            if viewModel.isLoadingProfile {
                
                ZStack(alignment: .center) {
                    HStack(alignment: .center, spacing: 0) {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .foregroundColor(Color.black)
                        Spacer()
                    }
                }
                .frame(height: 100)
            }
            else {
             
                FixedVerticalSpacer(height: 45)
                
                Text(viewModel.profileName)
                    .font(FontLibrary.sfProTextSemibold.font(size: 25))
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .multilineTextAlignment(.center)
                
                FixedVerticalSpacer(height: 9)
                
                Text(viewModel.joinedOnText)
                    .font(FontLibrary.sfProTextRegular.font(size: 11))
                    .foregroundColor(ColorPalette.gtGrey.color)
                    .multilineTextAlignment(.center)
                
                FixedVerticalSpacer(height: 35)
            }
        }
        .background(Color.white)
    }
}
