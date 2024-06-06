//
// Created on 6/6/24.
// Copyright © 2024 Turo Open Source. All rights reserved.
//

import Foundation

protocol StaticStorageRegistering {
    associatedtype Storage: AnyObject
    static var staticStorageRegistry: [String: WeakWrapper<Storage>] { get set }

    static func register<T>(staticStorage: Storage, for type: T.Type)
    static func staticStorage<T>(for type: T.Type) -> Storage?
    static func invalidate(staticStorage: Storage)
}

extension StaticStorageRegistering {

    static func register<T>(staticStorage: Storage, for type: T.Type) {
        let key = String(describing: type)
        staticStorageRegistry[key] = WeakWrapper(staticStorage)
    }

    static func staticStorage<T>(for type: T.Type) -> Storage? {
        let key = String(describing: type)
        return staticStorageRegistry[key]?.wrappedValue
    }

    static func invalidate(staticStorage: Storage) {
        for (key, value) in staticStorageRegistry {
            if value.wrappedValue === staticStorage {
                staticStorageRegistry.removeValue(forKey: key)
                return
            }
        }
    }

}
