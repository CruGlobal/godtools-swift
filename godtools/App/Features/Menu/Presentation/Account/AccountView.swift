//
//  AccountView.swift
//  godtools
//
//  Created by Levi Eggert on 11/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct AccountView: View {
    
    @ObservedObject private var viewModel: AccountViewModel
        
    init(viewModel: AccountViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(alignment: .leading, spacing: 0) {
                                        
                    AccountUserDetailsView(viewModel: viewModel)
                                        
                    AccountSectionsView(viewModel: viewModel, geometry: geometry)
                }
            }
        }
        .navigationTitle(viewModel.navTitle)
        .navigationBarBackButtonHidden(true)
        .background(Color.getColorWithRGB(red: 245, green: 245, blue: 245, opacity: 1))
        .edgesIgnoringSafeArea(.bottom)
    }
}
