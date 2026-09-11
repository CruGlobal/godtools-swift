//
//  FeaturedLessonsView.swift
//  godtools
//
//  Created by Rachael Skeath on 7/13/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct FeaturedLessonsView: View {

    private static let cardsTopSpacing: CGFloat = 22
    private static let cardsBottomSpacing: CGFloat = 5
    private static let cardSpacing: CGFloat = 24

    private let geometry: GeometryProxy
    private let contentHorizontalInsets: CGFloat

    @ObservedObject private var viewModel: LessonsViewModel

    init(
        viewModel: LessonsViewModel,
        geometry: GeometryProxy,
        contentHorizontalInsets: CGFloat
    ) {

        self.viewModel = viewModel
        self.geometry = geometry
        self.contentHorizontalInsets = contentHorizontalInsets
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

                HStack(alignment: .top, spacing: FeaturedLessonsView.cardSpacing) {

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
                .padding([.top], LessonCardView.shadowClippingInsetTop)
                .padding([.bottom], LessonCardView.shadowClippingInsetBottom)
            }
            .padding([.top], FeaturedLessonsView.cardsTopSpacing - LessonCardView.shadowClippingInsetTop)
            .padding([.bottom], FeaturedLessonsView.cardsBottomSpacing - LessonCardView.shadowClippingInsetBottom)
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
