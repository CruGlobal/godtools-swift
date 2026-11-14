//
//  ToolsHeaderView.swift
//  godtools
//
//  Created by Jason Bennett on 11/5/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import SwiftUI

struct ToolsHeaderView: View {

    @ObservedObject private var viewModel: ToolsViewModel

    init(viewModel: ToolsViewModel) {

        self.viewModel = viewModel
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 0) {

            Text(viewModel.headerTitle)
                .font(FontLibrary.sfProTextRegular.font(size: 28))
                .foregroundColor(ColorPalette.gtGrey.color)

            Text(viewModel.strings.subtitle)
                .font(FontLibrary.sfProTextRegular.font(size: 14))
                .foregroundColor(ColorPalette.gtGrey.color)
                .padding([.top], 7)
        }
    }
}

// MARK: - Preview

struct ToolsHeaderView_Preview: PreviewProvider {

    static var previews: some View {

        ToolsHeaderView(
            viewModel: AllToolsView_Preview.getToolsViewModel()
        )
    }
}
