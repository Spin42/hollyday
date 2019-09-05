class PtoMessage
  def self.render params
    if params[:dates] && params[:dates].size == 1
      dates = params[:dates]
      dates << params[:dates].first
      params[:webclient].chat_postEphemeral(
        user: params[:user],
        channel: params[:channel],
        text: "You're some personal time off on #{dates.first.strftime(DateUtils::LONG_FORMAT)}",
        attachments: self.attachments(dates))
    elsif params[:dates].size == 2
      params[:webclient].chat_postEphemeral(
        user: params[:user],
        channel: params[:channel],
        text: "You're taking some personal time off from #{params[:dates].first.strftime(DateUtils::LONG_FORMAT)} to #{params[:dates].last.strftime(DateUtils::LONG_FORMAT)}",
        attachments: self.attachments(params[:dates]))
    else
      params[:webclient].chat_postEphemeral(
        user: params[:user],
        channel: params[:channel],
        text: ":thinking_face: Please ask me for 'help' if you don't know how to book pto..."
      )
    end
  end

  def self.attachments dates
    return [
      {
        "callback_id": "pto_confirmation",
        "fallback": "Confirm",
        "attachment_type": "default",
        "actions":[
          {
            "name": "pto_confirm",
            "text": "Confirm",
            "type": "button",
            "value": dates.to_json,
            "style": "primary"
          },
          {
            "name": "pto_discard",
            "text": "Discard",
            "type": "button",
            "style": "danger"
          }
        ]
      }
    ]
  end
end
