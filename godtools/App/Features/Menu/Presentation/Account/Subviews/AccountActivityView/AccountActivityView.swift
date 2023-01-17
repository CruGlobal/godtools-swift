//
//  AccountActivityView.swift
//  godtools
//
//  Created by Rachael Skeath on 1/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct AccountActivityView: View {
    
    @ObservedObject var viewModel: AccountViewModel
    
    var body: some View {
        
        VStack {
            
            Text("Your Badges")
            
            ForEach(viewModel.badges) { badge in
                Text("id: \(badge.id), progress: \(badge.progressTarget), isEarned: \(badge.isEarned ? "yes" : "no")")
            }
        }
    }
}
