//
//  GetAppUILayoutDirectionUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 9/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class GetAppUILayoutDirectionUseCaseTests: QuickSpec {
    
    override class func spec() {
        
        describe("User is viewing the app UI layout.") {
         
            context("When the device is in a left to right language and the user preferred language is in the right to left language Arabic.") {
                
                let getAppLanguagesListRepository = TestsGetAppLanguagesListRepository(appLanguagesCodes: [.arabic, .english, .french, .spanish])
                let getUserPreferredAppLanguageRepository = TestsGetUserPreferredAppLanguageRepository(userAppLanguageCode: .arabic)
                let getDeviceAppLanguageRepository = TestsGetDeviceLanguageRepository(deviceLanguageCode: .english)
                
                let getAppUILayoutDirectionUseCase = GetInterfaceLayoutDirectionUseCase(
                    getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase(
                        getAppLanguagesListRepositoryInterface: getAppLanguagesListRepository,
                        getUserPreferredAppLanguageRepositoryInterface: getUserPreferredAppLanguageRepository,
                        getDeviceAppLanguageRepositoryInterface: getDeviceAppLanguageRepository
                    ),
                    getAppLanguageRepositoryInterface: GetAppLanguageRepository(
                        appLanguagesRepository: AppLanguagesRepository()
                    ),
                    getUserPreferredAppLanguageRepositoryInterface: getUserPreferredAppLanguageRepository
                )
                
                it("The application UI should be in a right to left layout.") {
                    
                    waitUntil { done in
                        
                        var layoutDirectionRef: AppInterfaceLayoutDirectionDomainModel?
                        
                        _ = getAppUILayoutDirectionUseCase.getLayoutDirectionPublisher()
                            .sink { (layoutDirection: AppInterfaceLayoutDirectionDomainModel) in
                                
                                layoutDirectionRef = layoutDirection
                                
                                done()
                            }
                        
                        expect(layoutDirectionRef).to(equal(.rightToLeft))
                    }
                }
            }
            
            context("When the device is in a right to left language and the user preferred language is in the left to right language English.") {
                
                let getAppLanguagesListRepository = TestsGetAppLanguagesListRepository(appLanguagesCodes: [.arabic, .english, .french, .spanish])
                let getUserPreferredAppLanguageRepository = TestsGetUserPreferredAppLanguageRepository(userAppLanguageCode: .english)
                let getDeviceAppLanguageRepository = TestsGetDeviceLanguageRepository(deviceLanguageCode: .arabic)
                
                let getAppUILayoutDirectionUseCase = GetInterfaceLayoutDirectionUseCase(
                    getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase(
                        getAppLanguagesListRepositoryInterface: getAppLanguagesListRepository,
                        getUserPreferredAppLanguageRepositoryInterface: getUserPreferredAppLanguageRepository,
                        getDeviceAppLanguageRepositoryInterface: getDeviceAppLanguageRepository
                    ),
                    getAppLanguageRepositoryInterface: GetAppLanguageRepository(
                        appLanguagesRepository: AppLanguagesRepository()
                    ),
                    getUserPreferredAppLanguageRepositoryInterface: getUserPreferredAppLanguageRepository
                )
                
                it("The application UI should be in a left to right layout.") {
                    
                    waitUntil { done in
                        
                        var layoutDirectionRef: AppInterfaceLayoutDirectionDomainModel?
                        
                        _ = getAppUILayoutDirectionUseCase.getLayoutDirectionPublisher()
                            .sink { (layoutDirection: AppInterfaceLayoutDirectionDomainModel) in
                                
                                layoutDirectionRef = layoutDirection
                                
                                done()
                            }
                        
                        expect(layoutDirectionRef).to(equal(.leftToRight))
                    }
                }
            }
        }
    }
}
