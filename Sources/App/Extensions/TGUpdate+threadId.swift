import telegram_vapor_bot

extension TGUpdate {
	var threadId: Int? {
		self.message?.chat.isForum == true ? self.message?.messageThreadId : nil
	}
}