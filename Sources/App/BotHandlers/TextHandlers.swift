import telegram_vapor_bot
import Vapor

final class TextHandlers {
    static func addHandlers(app: Vapor.Application, bot: TGBotPrtcl) {
        repeatHandler(app: app, bot: bot)
        parenthesesBalanceHandler(app: app, bot: bot)
    }

    private static func parenthesesBalanceHandler(app: Vapor.Application, bot: TGBotPrtcl) {
        let handler = TGMessageHandler(filters: .text) { update, bot in
            guard let chatId = update.message?.chat.id,
                  try FeatureSwitch.query(on: app.db)
                  .filter(\.$chatId, .equal, chatId)
                  .filter(\.$feature, .equal, .parenthesisBalancer)
                  .first()
                  .wait()?.disabled != true else { return }

            guard let text = update.message?.text else {
                return
            }

            let delta = text.reduce(0) { partial, char in
                switch char {
                case "(", "（": return partial + 1
                case ")", "）": return partial > 0 ? partial - 1 : 0
                default: return partial
                }
            }

            if delta > 0 {
                let replyText = String(repeatElement(")", count: delta))
                try update.message?.reply(text: replyText, bot: bot)
            }
        }
        bot.connection.dispatcher.add(handler)
    }

    private static func repeatHandler(app: Vapor.Application, bot: TGBotPrtcl) {
        let handler = TGMessageHandler(filters: .text) { update, bot in
            guard let chat = update.message?.chat, let text = update.message?.text else { return }

            guard try FeatureSwitch.query(on: app.db)
                  .filter(\.$chatId, .equal, chat.id)
                  .filter(\.$feature, .equal, .repeater)
                  .first()
                  .wait()?.disabled != true else { return }

            guard let history = try ChatMessageHistory.query(on: app.db)
                .filter(\.$chatId, .equal, chat.id)
                .first()
                .wait()
            else {
                do {
                    try ChatMessageHistory(chatId: chat.id, last1: text, last2: text, disabled: false).save(on: app.db).wait()
                } catch {
                    throw error
                }
                return
            }

            if history.last1 == text, history.last2 != text {
                try update.message?.reply(text: text, bot: bot)
                history.last2 = text

                try history.save(on: app.db).wait()

            } else if history.last1 != text {
                history.last1 = text
                try history.save(on: app.db).wait()
            }
        }
        bot.connection.dispatcher.add(handler)
    }
}
