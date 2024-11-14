import KeychainAccess
import Foundation

// MARK: - Keychain Wrapper
final class KeychainWrapper {
    static let standard = KeychainWrapper()
    private let keychain: Keychain
    
    // MARK: - Error Type
    enum KeychainError: LocalizedError {
        case saveError(String)
        case readError(String)
        case deleteError(String)
        
        var errorDescription: String? {
            switch self {
            case .saveError(let message):
                return "保存数据失败: \(message)"
            case .readError(let message):
                return "读取数据失败: \(message)"
            case .deleteError(let message):
                return "删除数据失败: \(message)"
            }
        }
    }
    
    init() {
        // 创建带有访问组的 Keychain 实例，支持多 target 共享数据
        self.keychain = Keychain(service: "com.yourapp.keychain")
            .accessibility(.afterFirstUnlock) // 设置访问级别
    }
    
    // MARK: - Public Methods
    
    /// 安全地存储字符串
    func set(_ value: String, forKey key: String) throws {
        do {
            try keychain.set(value, key: key)
        } catch {
            throw KeychainError.saveError(error.localizedDescription)
        }
    }
    
    /// 安全地获取字符串
    func string(forKey key: String) throws -> String? {
        do {
            return try keychain.get(key)
        } catch {
            throw KeychainError.readError(error.localizedDescription)
        }
    }
    
    /// 安全地存储数据
    func set(_ data: Data, forKey key: String) throws {
        do {
            try keychain.set(data, key: key)
        } catch {
            throw KeychainError.saveError(error.localizedDescription)
        }
    }
    
    /// 安全地获取数据
    func data(forKey key: String) throws -> Data? {
        do {
            return try keychain.getData(key)
        } catch {
            throw KeychainError.readError(error.localizedDescription)
        }
    }
    
    /// 安全地删除特定键的数据
    func remove(_ key: String) throws {
        do {
            try keychain.remove(key)
        } catch {
            throw KeychainError.deleteError(error.localizedDescription)
        }
    }
    
    /// 安全地删除所有数据
    func removeAllKeys() {
        try? keychain.removeAll()
    }
    
    // MARK: - Generic Methods
    
    /// 存储可编码对象
    func setObject<T: Encodable>(_ object: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(object)
        try set(data, forKey: key)
    }
    
    /// 获取可解码对象
    func object<T: Decodable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard let data = try data(forKey: key) else { return nil }
        return try JSONDecoder().decode(type, from: data)
    }
}

// MARK: - Convenience Extensions
extension KeychainWrapper {
    /// 检查键是否存在
    func containsKey(_ key: String) -> Bool {
        (try? string(forKey: key)) != nil || (try? data(forKey: key)) != nil
    }
    
    /// 安全地更新现有值
    func update(_ value: String, forKey key: String) throws {
        if containsKey(key) {
            try remove(key)
        }
        try set(value, forKey: key)
    }
}
