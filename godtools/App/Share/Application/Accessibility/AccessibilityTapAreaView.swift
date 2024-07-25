//
//  AccessibilityTapAreaView.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import SwiftUI

// NOTE: I placed this within a parent ZStack where the parent ZStack had an onTapGesture.  When using XCUITest to query the parent ZStack the tap would hit within the elements
// of the ZStack and sometimes it would hit a button within the parent ZStack.  So far placing this element with the parent ZStack and querying for this element and calling tap
// will have the same effect as tapping the parent ZStack. Example in ToolCardView.swift. ~Levi 

struct AccessibilityTapAreaView: View {
    
    private let accessibilityIdentifier: String
    
    init(accessibilityIdentifier: String) {
        
        self.accessibilityIdentifier = accessibilityIdentifier
    }
    
    var body: some View {
        
        ZStack {
            Color.clear
        }
        .frame(width: 1, height: 1)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}
