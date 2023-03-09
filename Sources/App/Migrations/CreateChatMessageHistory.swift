import Fluent
import Vapor

struct CreateChatMessageHistory: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("chat_message_history")
            .id()
            .field("chat_id", .int64, .required)
            .field("last_1", .string, .required)
            .field("last_2", .string, .required)
            .field("disabled", .bool, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("chat_message_history").delete()
    }
}