//
//  FeaturedLessonsView.swift
//  godtools
//
//  Created by Rachael Skeath on 7/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct FeaturedLessonsView: View {

    private let geometry: GeometryProxy
    private let contentHorizontalInsets: CGFloat
    private let lessonCardSpacing: CGFloat

    @ObservedObject private var viewModel: LessonsViewModel

    init(
        viewModel: LessonsViewModel,
        geometry: GeometryProxy,
        contentHorizontalInsets: CGFloat,
        lessonCardSpacing: CGFloat = DashboardView.toolCardVerticalSpacing
    ) {

        self.viewModel = viewModel
        self.geometry = geometry
        self.contentHorizontalInsets = contentHorizontalInsets
        self.lessonCardSpacing = lessonCardSpacing
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 0) {

            Text(viewModel.strings.featuredTitle)
                .font(FontLibrary.sfProTextRegular.font(size: 22))
                .foregroundColor(ColorPalette.gtGrey.color)
                .padding([.leading, .trailing], contentHorizontalInsets)

            Text(viewModel.strings.featuredSubtitle)
                .font(FontLibrary.sfProTextRegular.font(size: 14))
                .foregroundColor(ColorPalette.gtGrey.color)
                .padding([.top], 3)
                .padding([.leading, .trailing], contentHorizontalInsets)

            ScrollView(.horizontal, showsIndicators: false) {

                // NOTE: We need HStack here instead of LazyHStack because our card heights have dynamic heights to them and this allows the HStack to wrap the tallest card.
                HStack(alignment: .top, spacing: lessonCardSpacing) {

                    ForEach(viewModel.featuredLessons) { (featuredLesson: FeaturedLessonDomainModel) in

                        LessonCardView(
                            viewModel: viewModel.getFeaturedLessonViewModel(featuredLesson: featuredLesson),
                            geometry: geometry,
                            layout: .featured,
                            cardTappedClosure: {

                                viewModel.featuredLessonTapped(featuredLesson: featuredLesson)
                            }
                        )
                    }
                }
                .padding([.leading, .trailing], contentHorizontalInsets)
                // NOTE: The cards cast a shadow beyond their frame, which the ScrollView would otherwise clip. ~Rachael
                .padding([.top, .bottom], LessonCardView.shadowClippingInset)
            }
            .padding([.top], lessonCardSpacing - LessonCardView.shadowClippingInset)
        }
    }
}

// MARK: - Preview

struct FeaturedLessonView_Preview: PreviewProvider {

    static var previews: some View {

        GeometryReader { geometry in

            FeaturedLessonsView(
                viewModel: LessonsView_Preview.getLessonsViewModel(),
                geometry: geometry,
                contentHorizontalInsets: 20
            )
        }
    }
}
