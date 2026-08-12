//
//  LaunchCountCache.swift
//  godtools
//
//  Created by Levi Eggert on 8/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import RepositorySync

final class LaunchCountCache: LaunchCountCacheInterface {

    private static let sharedLaunchCountId: String = "LaunchCountCache.sharedLaunchCountId"

    let persistence: any Persistence<LaunchCountDataModel, LaunchCountDataModel>

    init(persistence: any Persistence<LaunchCountDataModel, LaunchCountDataModel>) {

        self.persistence = persistence
    }

    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }

    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<LaunchCountDataModel, LaunchCountDataModel, SwiftLaunchCount>? {
        return persistence as? SwiftRepositorySyncPersistence<LaunchCountDataModel, LaunchCountDataModel, SwiftLaunchCount>
    }

    private func getRealmPersistence() -> RealmRepositorySyncPersistence<LaunchCountDataModel, LaunchCountDataModel, RealmLaunchCount>? {
        return persistence as? RealmRepositorySyncPersistence<LaunchCountDataModel, LaunchCountDataModel, RealmLaunchCount>
    }

    @MainActor func getLaunchCountChangedPublisher() -> AnyPublisher<Int, Never> {

        return persistence
            .observeCollectionChangesPublisher()
            .map { [weak self] _ in
                return self?.getLaunchCount() ?? 0
            }
            .replaceError(with: 0)
            .eraseToAnyPublisher()
    }

    func getLaunchCount() -> Int {

        do {

            let dataModel: LaunchCountDataModel? = try persistence.getDataModel(id: LaunchCountCache.sharedLaunchCountId)

            return dataModel?.launchCount ?? 0
        }
        catch let error {

            assertionFailure("\n LaunchCountCache failed to get launch count with error: \(error)")

            return 0
        }
    }

    func storeLaunchCount(count: Int) async throws {

        let dataModel = LaunchCountDataModel(
            id: LaunchCountCache.sharedLaunchCountId,
            launchCount: count
        )

        _ = try await persistence.writeObjects(
            externalObjects: [dataModel],
            writeOption: nil,
            getOption: nil
        )
    }
}
