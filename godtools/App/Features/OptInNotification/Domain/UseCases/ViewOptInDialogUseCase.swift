//
//  ViewOptInDialogUseCase.swift
//  godtools
//
//  Created by Jason Bennett on 3/25/25.
//  Copyright © 2025 Cru. All rights reserved.
//

//import Combine
//import Foundation
//
//class ViewOptInDialogUseCase {
//
//    private let getInterfaceStringsRepository: GetOptInDialogInterfaceStringsRepositoryInterface
//
//    init(getInterfaceStringsRepository: GetOptInDialogInterfaceStringsRepositoryInterface) {
//        
//        self.getInterfaceStringsRepository = getInterfaceStringsRepository
//    }
//
//    func viewPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewOptInDialogDomainModel, Never> {
//
//        return getInterfaceStringsRepository
//            .getStringsPublisher(translateInLanguage: appLanguage)
//            .map {
//                ViewOptInDialogDomainModel(interfaceStrings: $0)
//            }
//            .eraseToAnyPublisher()
//    }
//}
