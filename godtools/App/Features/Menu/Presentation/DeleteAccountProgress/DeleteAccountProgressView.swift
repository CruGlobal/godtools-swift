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
                
                Text(viewModel.title)
                    .foregroundColor(Color.black)
                    .font(FontLibrary.sfProTextRegular.font(size: 18))
                    .multilineTextAlignment(.center)
                
                Text(viewModel.deleteStatus)
                    .foregroundColor(Color.black)
                    .font(FontLibrary.sfProTextRegular.font(size: 16))
                    .multilineTextAlignment(.center)
                    .padding(EdgeInsets(top: 7, leading: 0, bottom: 0, trailing: 0))
                
                HStack(alignment: .center, spacing: 0) {
                    
                    Spacer()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .foregroundColor(Color.black)
                        .padding(EdgeInsets(top: 15, leading: 0, bottom: 0, trailing: 0))
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
        }
    }
}
