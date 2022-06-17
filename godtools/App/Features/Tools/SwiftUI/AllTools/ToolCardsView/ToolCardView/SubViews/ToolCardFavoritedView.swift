//
//  ToolCardFavoritedView.swift
//  godtools
//
//  Created by Rachael Skeath on 5/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct ToolCardFavoritedView: View {
    
    let isFavorited: Bool
    
    var body: some View {
        Image(isFavorited ? ImageCatalog.favoritedCircle.name : ImageCatalog.unfavoritedCircle.name)
            .padding(10)
    }
}

struct ToolCardFavoritedView_Previews: PreviewProvider {
    static var previews: some View {
        ToolCardFavoritedView(isFavorited: false)
            .previewLayout(.sizeThatFits)
    }
}
