import Vapor
import Fluent

final class ChatMessageHistory: Model {
    static let schema = "chat_message_history"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "chat_id")
    var chatId: Int64

    @Field(key: "last_1")
    var last1: String

    @Field(key: "last_2")
    var last2: String

    @Field(key: "disabled")
    var disabled: Bool

    init() {}

    init(id: UUID? = nil, chatId: Int64, last1: String, last2: String, disabled: Bool = true) {
        self.id = id
        self.chatId = chatId
        self.last1 = last1
        self.last2 = last2
        self.disabled = disabled
    }
}