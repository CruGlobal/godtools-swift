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
    private let lessonTappedClosure: ((_ featuredLesson: FeaturedLessonDomainModel) -> Void)?
    
    @ObservedObject private var viewModel: FavoritesViewModel
    
    init(viewModel: FavoritesViewModel, geometry: GeometryProxy, contentHorizontalInsets: CGFloat, lessonCardSpacing: CGFloat = DashboardView.toolCardVerticalSpacing, lessonTappedClosure: ((_ featuredLesson: FeaturedLessonDomainModel) -> Void)?) {
        
        self.viewModel = viewModel
        self.geometry = geometry
        self.contentHorizontalInsets = contentHorizontalInsets
        self.lessonCardSpacing = lessonCardSpacing
        self.lessonTappedClosure = lessonTappedClosure
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text(viewModel.featuredLessonsTitle)
                .font(FontLibrary.sfProTextRegular.font(size: 22))
                .foregroundColor(ColorPalette.gtGrey.color)
                .padding(.leading, contentHorizontalInsets)
            
            LazyVStack(alignment: .center, spacing: lessonCardSpacing) {
                
                ForEach(viewModel.featuredLessons) { (featuredLesson: FeaturedLessonDomainModel) in
                    
                    LessonCardView(
                        viewModel: viewModel.getFeaturedLessonViewModel(featuredLesson: featuredLesson),
                        geometry: geometry,
                        cardTappedClosure: {
                        
                        lessonTappedClosure?(featuredLesson)
                    })
                }
            }
            .padding([.top], lessonCardSpacing)
        }
    }
}

// MARK: - Preview

struct FeaturedLessonView_Preview: PreviewProvider {
    
    static var previews: some View {
        
        GeometryReader { geometry in
            
            FeaturedLessonsView(
                viewModel: FavoritesView_Preview.getFavoritesViewModel(),
                geometry: geometry,
                contentHorizontalInsets: 20,
                lessonTappedClosure: nil
            )
        }
    }
}
