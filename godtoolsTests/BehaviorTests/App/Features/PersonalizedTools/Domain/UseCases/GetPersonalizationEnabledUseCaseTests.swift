//
//  GetPersonalizationEnabledUseCaseTests.swift
//  godtoolsTests
//
//  Created by Jason Bennett on 11/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetPersonalizationEnabledUseCaseTests {

    struct TestArgument {
        let personalizationIsEnabled: Bool?
        let expectedIsEnabled: Bool
    }

    @Test(
        """
        Given: Remote config contains a value for whether personalization is enabled.
        When: Personalization enabled is requested.
        Then: The remote config value is returned.
        """,
        arguments: [
            TestArgument(personalizationIsEnabled: true, expectedIsEnabled: true),
            TestArgument(personalizationIsEnabled: false, expectedIsEnabled: false)
        ]
    )
    func returnsTheRemoteConfigValue(argument: TestArgument) async {

        let useCase = getUseCase(remoteConfig: getRemoteConfig(personalizationIsEnabled: argument.personalizationIsEnabled))

        let isEnabled: Bool = await useCase.execute()

        #expect(isEnabled == argument.expectedIsEnabled)
    }

    @Test(
        """
        Given: Remote config does not contain a value for whether personalization is enabled.
        When: Personalization enabled is requested.
        Then: Personalization is disabled.
        """
    )
    func isDisabledWhenRemoteConfigHasNoValue() async {

        let useCase = getUseCase(remoteConfig: getRemoteConfig(personalizationIsEnabled: nil))

        let isEnabled: Bool = await useCase.execute()

        #expect(isEnabled == false)
    }

    @Test(
        """
        Given: Remote config is unavailable.
        When: Personalization enabled is requested.
        Then: Personalization is disabled.
        """
    )
    func isDisabledWhenRemoteConfigIsUnavailable() async {

        let useCase = getUseCase(remoteConfig: nil)

        let isEnabled: Bool = await useCase.execute()

        #expect(isEnabled == false)
    }
}

extension GetPersonalizationEnabledUseCaseTests {

    private func getRemoteConfig(personalizationIsEnabled: Bool?) -> RemoteConfigDataModel {

        return RemoteConfigDataModel(
            globalActivityIsEnabled: nil,
            toolContentFeaturePageCollectionPageEnabled: nil,
            optInNotificationEnabled: nil,
            optInNotificationPromptLimit: nil,
            optInNotificationTimeInterval: nil,
            personalizationIsEnabled: personalizationIsEnabled
        )
    }

    private func getUseCase(remoteConfig: RemoteConfigDataModel?) -> GetPersonalizationEnabledUseCase {

        return GetPersonalizationEnabledUseCase(
            remoteConfigRepository: RemoteConfigRepository(
                remoteDatabase: FakeRemoteConfigRemoteDatabase(remoteConfig: remoteConfig)
            )
        )
    }
}
