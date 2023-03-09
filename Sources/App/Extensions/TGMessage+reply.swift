import Foundation
import telegram_vapor_bot

extension TGMessage {
    func replyWithQuote(text: String, bot: TGBotPrtcl, messageThreadId: Int? = nil, parseMode: TGParseMode? = nil, replyMarkup: TGReplyMarkup? = nil) throws {
        let params = TGSendMessageParams(
            chatId: .chat(chat.id),
            messageThreadId: messageThreadId,
            text: text,
            parseMode: parseMode, 
            replyToMessageId: messageId,
            replyMarkup: replyMarkup
        )
        try bot.sendMessage(params: params)
    }
}