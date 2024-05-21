//
//  DeleteAccountProgressView.swift
//  godtools
//
//  Created by Levi Eggert on 5/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct DeleteAccountProgressView: View {
    
    private let backgroundColor: Color
    
    @ObservedObject private var viewModel: DeleteAccountProgressViewModel
    
    init(viewModel: DeleteAccountProgressViewModel, backgroundColor: Color) {
        
        self.viewModel = viewModel
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack(alignment: .center, spacing: 0) {
                
                Spacer()
                
                Text(viewModel.interfaceStrings.title)
                    .foregroundColor(Color.black)
                    .font(FontLibrary.sfProTextRegular.font(size: 18))
                    .multilineTextAlignment(.center)
                                
                HStack(alignment: .center, spacing: 0) {
                    
                    Spacer()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .foregroundColor(Color.black)
                    
                    Spacer()
                }
                .padding(EdgeInsets(top: 15, leading: 0, bottom: 0, trailing: 0))
                
                Spacer()
            }
            .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
        }
    }
}
