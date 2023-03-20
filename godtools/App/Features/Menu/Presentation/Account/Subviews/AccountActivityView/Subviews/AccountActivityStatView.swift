//
//  AccountActivityStatView.swift
//  godtools
//
//  Created by Rachael Skeath on 3/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct AccountActivityStatView: View {
    
    let stat: UserActivityStatDomainModel
    
    var body: some View {
        
        HStack {
            
            Image(stat.iconImageName)
            
            VStack {
                
                Text(stat.value)
                Text(stat.text)
            }
            
        }
    }
}
