import Vapor
import Fluent

final class FeatureSwitch: Model, Content {
    static let schema = "feature_switch"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "chat_id")
    var chatId: Int64

    @Field(key: "feature")
    var feature: Feature

    @Field(key: "disabled")
    var disabled: Bool

    init() {}

    init(id: UUID? = nil, chatId: Int64, feature: Feature, disabled: Bool = true) {
        self.id = id
        self.chatId = chatId
        self.feature = feature
        self.disabled = disabled
    }
}

extension FeatureSwitch {
    struct Migration: AsyncMigration {
        func prepare(on database: Database) async throws {
            try await database.schema("feature_switch")
                .id()
                .field("chat_id", .int64, .required)
                .field("feature", .string, .required)
                .field("disabled", .bool, .required)
                .unique(on: "chat_id", "feature")
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema("feature_switch").delete()
        }
    }
}

enum Feature: String, Codable, CaseIterable {
    case repeater
    case parenthesisBalancer
    case slashbot

    var callbackEvent: CallbackEvent {
        switch self {
        case .repeater: return .toggleRepeater
        case .parenthesisBalancer: return .toggleParenthesisBalancer
        case .slashbot: return .toggleSlashbot
        }
    }

    var name: String {
        switch self {
            case .repeater: return "复读"
            case .parenthesisBalancer: return "括号"
            case .slashbot: return "/"
        }
    }
}