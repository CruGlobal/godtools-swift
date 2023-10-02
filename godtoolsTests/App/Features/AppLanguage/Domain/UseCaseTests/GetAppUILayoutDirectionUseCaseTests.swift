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
                
                let getAppUILayoutDirectionUseCase = GetAppUILayoutDirectionUseCase(
                    getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase(
                        getAppLanguagesListRepositoryInterface: getAppLanguagesListRepository,
                        getUserPreferredAppLanguageRepositoryInterface: getUserPreferredAppLanguageRepository,
                        getDeviceAppLanguageRepositoryInterface: getDeviceAppLanguageRepository
                    ),
                    getAppLanguageRepositoryInterface: GetAppLanguageRepository(
                        appLanguagesRepository: AppLanguagesRepository()
                    )
                )
                
                it("The application UI should be in a right to left layout.") {
                    
                    let layoutDirection: AppUILayoutDirectionDomainModel = getAppUILayoutDirectionUseCase.getLayoutDirection()
                                        
                    expect(layoutDirection).to(equal(.rightToLeft))
                }
            }
            
            context("When the device is in a right to left language and the user preferred language is in the left to right language English.") {
                
                let getAppLanguagesListRepository = TestsGetAppLanguagesListRepository(appLanguagesCodes: [.arabic, .english, .french, .spanish])
                let getUserPreferredAppLanguageRepository = TestsGetUserPreferredAppLanguageRepository(userAppLanguageCode: .english)
                let getDeviceAppLanguageRepository = TestsGetDeviceLanguageRepository(deviceLanguageCode: .arabic)
                
                let getAppUILayoutDirectionUseCase = GetAppUILayoutDirectionUseCase(
                    getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase(
                        getAppLanguagesListRepositoryInterface: getAppLanguagesListRepository,
                        getUserPreferredAppLanguageRepositoryInterface: getUserPreferredAppLanguageRepository,
                        getDeviceAppLanguageRepositoryInterface: getDeviceAppLanguageRepository
                    ),
                    getAppLanguageRepositoryInterface: GetAppLanguageRepository(
                        appLanguagesRepository: AppLanguagesRepository()
                    )
                )
                
                it("The application UI should be in a left to right layout.") {
                    
                    let layoutDirection: AppUILayoutDirectionDomainModel = getAppUILayoutDirectionUseCase.getLayoutDirection()
                                        
                    expect(layoutDirection).to(equal(.leftToRight))
                }
            }
        }
    }
}