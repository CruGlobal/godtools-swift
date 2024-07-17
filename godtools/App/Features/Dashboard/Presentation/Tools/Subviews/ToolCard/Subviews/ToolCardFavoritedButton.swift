//
//  ToolCardFavoritedButton.swift
//  godtools
//
//  Created by Rachael Skeath on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCardFavoritedButton: View {
    
    let isFavorited: Bool
    let tappedClosure: (() -> Void)?
    
    var body: some View {
        
        Button {
            
            tappedClosure?()
            
        } label: {
            
            Image(isFavorited ? ImageCatalog.favoritedCircle.name : ImageCatalog.unfavoritedCircle.name)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 36, height: 36)
                .clipped()
        }
        .frame(width: 44, height: 44)
    }
}

// MARK: - Preview

struct ToolCardFavoritedView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ToolCardFavoritedButton(isFavorited: false, tappedClosure: nil)
            .previewLayout(.sizeThatFits)
    }
}
