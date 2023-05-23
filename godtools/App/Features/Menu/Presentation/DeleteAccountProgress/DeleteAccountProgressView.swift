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
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text(viewModel.title)
                    .foregroundColor(Color.black)
                
                Text(viewModel.deleteStatus)
                    .foregroundColor(Color.black)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .foregroundColor(Color.black)
            }
        }
    }
}
