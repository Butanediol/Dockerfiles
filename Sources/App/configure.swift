import Fluent
import FluentSQLiteDriver
import Vapor
import telegram_vapor_bot

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.sqlite(.file("data/db.sqlite")), as: .sqlite)

    try configureTelegramBot(app)

    app.migrations.add(CreateChatMessageHistory())
    app.migrations.add(FeatureSwitch.Migration())

    // register routes
    try routes(app)
}

private func configureTelegramBot(_ app: Application) throws {
    guard let tgBotToken = Environment.get("TELEGRAM_BOT_TOKEN") else {
        app.logger.critical("TELEGRAM_BOT_TOKEN not set!")
        app.shutdown()
        exit(1)
    }

    if let tgBotUsername = Environment.get("TELEGRAM_BOT_USERNAME") {
        app.botUsername = tgBotUsername
    } else {
        app.logger.warning("TELEGRAM_BOT_USERNAME not set!")
    }
    let connection: TGConnectionPrtcl = TGLongPollingConnection()
    TGBot.configure(connection: connection, botId: tgBotToken, vaporClient: app.client)
    try TGBot.shared.start()

    Commandhandlers.addHandlers(app: app, bot: TGBot.shared)
    RegexpHandlers.addHandlers(app: app, bot: TGBot.shared)
    TextHandlers.addHandlers(app: app, bot: TGBot.shared)
}