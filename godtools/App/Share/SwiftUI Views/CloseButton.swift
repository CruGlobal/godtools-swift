//
//  CloseButton.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct CloseButton: View {
    
    let tapped: (() -> Void)
    
    var body: some View {
        Button {
            tapped()
        } label: {
            Image(ImageCatalog.navClose.name)
        }
        .frame(minWidth: 44, minHeight: 44)
    }
}
