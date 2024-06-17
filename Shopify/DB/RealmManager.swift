//
//  RealmManager.swift
//  Shopify
//
//  Created by Apple on 17/06/2024.
//

import Foundation
import RealmSwift

protocol RealmManagerProtocol {
    func add<T: Object>(_ object: T)
    func getAll<T: Object>(_ type: T.Type) -> Results<T>
    func deleteAll<T: Object>(_ type: T.Type)
    func query<T: Object>(_ type: T.Type, filter: String) -> Results<T>
    func update<T: Object>(_ type: T.Type, primaryKey: Any, with dictionary: [String: Any])
    func deleteAllThenAdd<T: Object>(_ object: T , _ type: T.Type)
}

class RealmManager :  RealmManagerProtocol{
    static let shared = RealmManager()
    private let realm = try! Realm()

    private init() { }

    // MARK: - CRUD Operations
    func add<T: Object>(_ object: T) {
        try! realm.write {
            realm.add(object)
        }
    }

    func getAll<T: Object>(_ type: T.Type) -> Results<T> {
        return realm.objects(type)
    }

    func deleteAll<T: Object>(_ type: T.Type) {
        let objects = realm.objects(type)
        try! realm.write {
            realm.delete(objects)
        }
    }
    
    func deleteAllThenAdd<T: Object>(_ object: T , _ type: T.Type){
        let objects = realm.objects(type)
        try! realm.write {
            realm.delete(objects)
            realm.add(object)
        }
    }

    func query<T: Object>(_ type: T.Type, filter: String) -> Results<T> {
        return realm.objects(type).filter(filter)
    }
    
    func update<T: Object>(_ type: T.Type, primaryKey: Any, with dictionary: [String: Any]) {
        if let object = realm.object(ofType: type, forPrimaryKey: primaryKey) {
            try! realm.write {
                for (key, value) in dictionary {
                    object.setValue(value, forKey: key)
                }
            }
        }
    }
}
