class AfkMessage
  def self.render params
    if params[:times].size == 2
      params[:webclient].chat_postEphemeral(
        user: params[:user],
        channel: params[:channel],
        text: "You're afk on #{params[:times].first.strftime(DateUtils::LONG_FORMAT)} from #{params[:times].first.in_time_zone("Europe/Brussels").strftime(DateUtils::TIME)} to #{params[:times].last.in_time_zone("Europe/Brussels").strftime(DateUtils::TIME)}",
        attachments: self.attachments(params[:times]))
    else
      params[:webclient].chat_postEphemeral(
        user: params[:user],
        channel: params[:channel],
        text: ":thinking_face: Please ask me for 'help' if you don't know how to book and afk..."
      )
    end
  end

  def self.attachments times
    return [
      {
        "callback_id": "afk_confirmation",
        "fallback": "Confirm",
        "attachment_type": "default",
        "actions":[
          {
            "name": "afk_confirm",
            "text": "Confirm",
            "type": "button",
            "value": times.to_json,
            "style": "primary"
          },
          {
            "name": "afk_discard",
            "text": "Discard",
            "type": "button",
            "style": "danger"
          }
        ]
      }
    ]
  end
end
