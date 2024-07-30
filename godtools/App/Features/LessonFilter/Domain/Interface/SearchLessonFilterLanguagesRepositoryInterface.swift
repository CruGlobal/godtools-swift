//
//  SearchLessonFilterLanguagesRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 7/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol SearchLessonFilterLanguagesRepositoryInterface {
    
    func getSearchResultsPublisher(for searchText: String, in lessonFilterLanguages: [LessonFilterLanguageDomainModel]) -> AnyPublisher<[LessonFilterLanguageDomainModel], Never>
}
