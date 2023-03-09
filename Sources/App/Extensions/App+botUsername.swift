import Vapor

struct TGBotUsernameKey: StorageKey {
    typealias Value = String
}

extension Application {
    var botUsername: String? {
        get {
            self.storage[TGBotUsernameKey.self]
        }
        set {
            self.storage[TGBotUsernameKey.self] = newValue
        }
    }
}