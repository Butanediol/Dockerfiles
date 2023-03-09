import telegram_vapor_bot
import Vapor

final class RegexpHandlers {
    static func addHandlers(app: Vapor.Application, bot: TGBotPrtcl) {
        slashHandler(app: app, bot: bot)
    }

    private static func slashHandler(app: Vapor.Application, bot: TGBotPrtcl) {
        enum Direction: Character {
            case active = "/"
            case passive = "\\"

            init?(rawValue: Character?) {
                switch rawValue {
                case .some("/"): self = .active
                case .some("\\"): self = .passive
                default: return nil
                }
            }
        }

        let regexp = try! NSRegularExpression(pattern: #"^(/|\\).*[\u4e00-\u9fa5]{1,}.*$"#)
        let handler = TGRegexpHandler(regexp: regexp) { update, bot in

            guard let chatId = update.message?.chat.id else { return }

            guard try FeatureSwitch.query(on: app.db)
                .filter(\.$chatId, .equal, chatId)
                .filter(\.$feature, .equal, Feature.slashbot)
                .first()
                .wait()?.disabled != true else { return }

            guard (update.message?.replyToMessage) != nil else {
                try update.message?.replyWithQuote(text: "你必须找个对象才能做！", bot: bot, messageThreadId: update.threadId)
                return
            }

            guard let message = update.message,
                  let word1 = message.parameters.first?.dropFirst(),
                  let direction = Direction(rawValue: message.parameters.first?.first)
            else { return }

            let word2 = message.parameters.dropFirst().first ?? ""

            guard let initiator = message.from, let reciever = message.replyToMessage?.from else {
                return
            }

            switch direction {
            case .active:
                try update.message?.replyWithQuote(
                    text: "[\(initiator.fullName.markdownV2Escaped)](tg://user?id=\(initiator.id)) \(word1) [\(reciever.fullName.markdownV2Escaped)](tg://user?id=\(reciever.id)) \(word2)",
                    bot: bot,
                    messageThreadId: update.threadId,
                    parseMode: .markdownV2
                )
            case .passive:
                try update.message?.replyWithQuote(
                    text: "[\(reciever.fullName.markdownV2Escaped)](tg://user?id=\(reciever.id)) \(word1) [\(initiator.fullName.markdownV2Escaped)](tg://user?id=\(initiator.id)) \(word2)",
                    bot: bot,
                    messageThreadId: update.threadId,
                    parseMode: .markdownV2
                )
            }
        }
        bot.connection.dispatcher.add(handler)
    }
}
