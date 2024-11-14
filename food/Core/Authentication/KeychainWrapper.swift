//
//  KeychainWrapper.swift
//  food
//
//  Created by toyousoft on 2024/11/13.
//

import KeychainAccess
import Foundation

// MARK: - Keychain Wrapper
final class KeychainWrapper {
    static let standard = KeychainWrapper()
    private let keychain: Keychain
    
    init() {
        // 创建一个带有特定服务名称的 Keychain 实例
        self.keychain = Keychain(service: "com.yourapp.keychain")
    }
    
    // MARK: - Public Methods
    
    /// 存储字符串
    func set(_ value: String, forKey key: String) throws {
        try keychain.set(value, key: key)
    }
    
    /// 获取字符串
    func string(forKey key: String) throws -> String? {
        try keychain.get(key)
    }
    
    /// 存储数据
    func set(_ data: Data, forKey key: String) throws {
        try keychain.set(data, key: key)
    }
    
    /// 获取数据
    func data(forKey key: String) throws -> Data? {
        try keychain.getData(key)
    }
    
    /// 删除特定键的数据
    func remove(_ key: String) throws {
        try keychain.remove(key)
    }
    
    /// 删除所有数据
    func removeAllKeys() {
        try? keychain.removeAll()
    }
}
