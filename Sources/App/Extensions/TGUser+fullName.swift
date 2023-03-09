import telegram_vapor_bot

extension TGUser {
    var fullName: String {
        firstName + (lastName ?? "")
    }
}