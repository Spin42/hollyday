class SickMessage
  def self.render params
    if params[:dates] && params[:dates].size == 1
      dates = params[:dates]
      dates << params[:dates].first

      if !(params[:am] && params[:pm])
        am_pm_suffix = "in the morning" if params[:am] && !params[:pm]
        am_pm_suffix = "in the afternoon" if !params[:am] && params[:pm]
      else
        am_pm_suffix = ""
      end

      params[:webclient].chat_postEphemeral(
        user: params[:user],
        channel: params[:channel],
        text: "You're sick leave on #{dates.first.strftime(DateUtils::LONG_FORMAT)} #{am_pm_suffix}",
        attachments: self.attachments(dates, params[:am], params[:pm]))
    elsif params[:dates].size == 2
      if !(params[:am] && params[:pm])
        am_pm_suffix = "in the morning" if params[:am] && !params[:pm]
        am_pm_suffix = "in the afternoon" if !params[:am] && params[:pm]
      else
        am_pm_suffix = ""
      end
      
      params[:webclient].chat_postEphemeral(
        user: params[:user],
        channel: params[:channel],
        text: "You're on sick leave from #{params[:dates].first.strftime(DateUtils::LONG_FORMAT)} to #{params[:dates].last.strftime(DateUtils::LONG_FORMAT)} #{am_pm_suffix}",
        attachments: self.attachments(params[:dates], params[:am], params[:pm]))
    else
      params[:webclient].chat_postEphemeral(
        user: params[:user],
        channel: params[:channel],
        text: ":thinking_face: Please ask me for 'help' if you don't know how to book pto..."
      )
    end
  end

  def self.attachments dates, am, pm
    return [
      {
        "callback_id": "sick_confirmation",
        "fallback": "Confirm",
        "attachment_type": "default",
        "actions":[
          {
            "name": "sick_confirm",
            "text": "Confirm",
            "type": "button",
            "value": [dates, am, pm].flatten.to_json,
            "style": "primary"
          },
          {
            "name": "sick_discard",
            "text": "Discard",
            "type": "button",
            "style": "danger"
          }
        ]
      }
    ]
  end
end
