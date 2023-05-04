//
//  MenuView.swift
//  godtools
//
//  Created by Levi Eggert on 5/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    
    @ObservedObject private var viewModel: MenuViewModel
    
    init(viewModel: MenuViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                
                
                
                VStack(alignment: .leading, spacing: 20) {
                 
                    Text("Menu is ready for SwiftUI")
                        .foregroundColor(Color.black)
                    
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 100, height: 200)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 100, height: 200)
                    
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 100, height: 200)
                    
                    Rectangle()
                        .fill(Color.yellow)
                        .frame(width: 100, height: 200)
                }
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                
                
                
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(Color.white)
    }
}
