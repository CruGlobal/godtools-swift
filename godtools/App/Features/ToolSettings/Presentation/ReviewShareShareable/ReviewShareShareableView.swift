//
//  ReviewShareShareableView.swift
//  godtools
//
//  Created by Levi Eggert on 6/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI
import GodToolsToolParser

struct ReviewShareShareableView: View {
    
    private let bottomSpacing: CGFloat = 30
    
    @ObservedObject var viewModel: ReviewShareShareableViewModel
    
    var body: some View {
        
        GeometryReader { geometry in
                        
            VStack(alignment: .center, spacing: 0) {
                
                Spacer()
                
                Image("tutorial_in_menu_english")
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: geometry.size.width, height: 15, alignment: .leading)
                
                Button(action: {
                    // button tapped
                }) {
                    
                    HStack(alignment: .center, spacing: 8) {
                        Image(ImageCatalog.navShare.name)
                        Text("Share Image")
                            .foregroundColor(.blue)
                    }
                }
                .frame(width: 200, height: 50, alignment: .center)
                .background(Color.white)
                .accentColor(.blue)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(.blue, lineWidth: 1)
                )
            }
            .frame(width: geometry.size.width)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: bottomSpacing, trailing: 0))
        }
        .background(Color.white)
    }
}

struct ReviewShareShareableViewPreview: PreviewProvider {
    
    static var previews: some View {
        
        ReviewShareShareableView(viewModel: ReviewShareShareableViewPreview.getReviewShareShareableViewModel())
    }
    
    static func getReviewShareShareableViewModel() -> ReviewShareShareableViewModel {
                
        return ReviewShareShareableViewModel(imageToShare: UIImage())
    }
}
