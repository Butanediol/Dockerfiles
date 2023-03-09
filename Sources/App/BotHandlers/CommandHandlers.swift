import Algorithms
import Fluent
import telegram_vapor_bot
import Vapor

final class Commandhandlers {
    static func addHandlers(app: Vapor.Application, bot: TGBotPrtcl) {
        settingsHandler(app: app, bot: bot)
        aiHandler(app: app, bot: bot)
    }

    private static func settingsHandler(app: Vapor.Application, bot: TGBotPrtcl) {
        func getFeatureStatus(chatId: Int64) throws -> [FeatureSwitch] {
            return try FeatureSwitch.query(on: app.db)
                .filter(\.$chatId, .equal, chatId)
                .all().wait()
        }

        func getKeyboard(featureStatus: [FeatureSwitch]) -> [[TGInlineKeyboardButton]] {
            Feature.allCases.map { feature in
                let status: String = featureStatus.first { $0.feature == feature }?.disabled == true ? "❌ 关着" : "✅ 开着"
                return [.init(text: "\(feature.name) \(status)", callbackData: feature.callbackEvent.callbackData)]
            }
        }

        let handler = TGCommandHandler(
            commands: ["/settings"],
            botUsername: app.botUsername
        ) { update, bot in
            guard let chatId = update.message?.chat.id else { return }
            let featureStatus = try getFeatureStatus(chatId: chatId)
            let keyboard = getKeyboard(featureStatus: featureStatus)
            let inlineKeyboardMarkup = TGInlineKeyboardMarkup(inlineKeyboard: keyboard)
            try update.message?.reply(
                text: "广告位招租",
                bot: bot,
                replyMarkup: .inlineKeyboardMarkup(inlineKeyboardMarkup)
            )
        }

        let callbackHandler = TGCallbackQueryHandler(pattern: "toggle*") { update, bot in
            guard let callbackData = update.callbackQuery?.data,
                  let chatId = update.callbackQuery?.message?.chat.id
            else {
                return
            }

            try CallbackEvent(rawValue: callbackData)?.execute(on: app.db, chatId: chatId)

            let featureStatus = try getFeatureStatus(chatId: chatId)
            let keyboard = getKeyboard(featureStatus: featureStatus)
            let inlineKeyboardMarkup = TGInlineKeyboardMarkup(inlineKeyboard: keyboard)

            try bot.editMessageText(params: .init(chatId: .chat(chatId), messageId: update.callbackQuery?.message?.messageId, text: "广告位招租", replyMarkup: inlineKeyboardMarkup))
        }
        bot.connection.dispatcher.add(handler)
        bot.connection.dispatcher.add(callbackHandler)
    }

    private static func aiHandler(app: Vapor.Application, bot: TGBotPrtcl) {
        let handler = TGCommandHandler(
            commands: ["/ai"],
            botUsername: app.botUsername
        ) { update, bot in
            guard let parameters = update.message?.parameters else { return }

            let response = try app.client.post(
                .init(string: "https://ai.azure.butanediol.me/run/help_me_write"),
                content: NotionAIRequest(data: [update.message?.replyToMessage?.text ?? "", parameters.joined()])
            )
            .wait()
            .content
            .decode(NotionAIResponse.self)

            let text: String = response.data.joined()
                .replacingOccurrences(of: "<p>", with: "")
                .replacingOccurrences(of: "</p>", with: "")
                .replacingOccurrences(of: "<ul>", with: "")
                .replacingOccurrences(of: "</ul>", with: "")
                .replacingOccurrences(of: "<br>", with: "\n")
                .replacingOccurrences(of: "</br>", with: "")
                .replacingOccurrences(of: "<table>", with: "")
                .replacingOccurrences(of: "</table>", with: "")
                .replacingOccurrences(of: "<td>", with: "")
                .replacingOccurrences(of: "</td>", with: "")
                .replacingOccurrences(of: "<tr>", with: "")
                .replacingOccurrences(of: "<li>", with: "")
                .replacingOccurrences(of: "</li>", with: "")
                .replacingOccurrences(of: "</tr>", with: "")
                .replacingOccurrences(of: "<th>", with: "")
                .replacingOccurrences(of: "</th>", with: "")
                .replacingOccurrences(of: "<tbody>", with: "")
                .replacingOccurrences(of: "</tbody>", with: "")
                .replacingOccurrences(of: "<thead>", with: "")
                .replacingOccurrences(of: "</thead>", with: "")

            try update.message?.replyWithQuote(
                text: text,
                bot: bot,
                parseMode: .html
            )
        }

        bot.connection.dispatcher.add(handler)
    }
}

struct NotionAIResponse: Content {
    let data: [String]
    let is_generating: Bool
    let duration: Double
    let average_duration: Double
}

struct NotionAIRequest: Content {
    let data: [String]
}

enum CallbackEvent: String, CaseIterable {
    case toggleRepeater
    case toggleParenthesisBalancer
    case toggleSlashbot

    var callbackData: String {
        rawValue
    }

    func execute(on db: Database, chatId: Int64) throws {
        let featureStatus = try FeatureSwitch.query(on: db)
            .filter(\.$chatId, .equal, chatId)
            .all().wait()
        switch self {
        case .toggleRepeater:
            let status = featureStatus.first { $0.feature == .repeater }
            if let status = status {
                status.disabled.toggle()
                try status.save(on: db).wait()
            } else {
                try FeatureSwitch(chatId: chatId, feature: .repeater, disabled: true)
                    .create(on: db).wait()
            }
        case .toggleParenthesisBalancer:
            let status = featureStatus.first { $0.feature == .parenthesisBalancer }
            if let status {
                status.disabled.toggle()
                try status.save(on: db).wait()
            } else {
                try FeatureSwitch(chatId: chatId, feature: .parenthesisBalancer, disabled: true)
                    .create(on: db).wait()
            }
        case .toggleSlashbot:
            let status = featureStatus.first { $0.feature == .slashbot }
            if let status {
                status.disabled.toggle()
                try status.save(on: db).wait()
            } else {
                try FeatureSwitch(chatId: chatId, feature: .slashbot, disabled: true)
                    .create(on: db).wait()
            }
        }
    }
}
