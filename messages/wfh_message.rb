class WfhMessage
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
        text: "You're working from home on #{dates.first.strftime(DateUtils::LONG_FORMAT)} #{am_pm_suffix}",
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
        text: "You're working from home from #{params[:dates].first.strftime(DateUtils::LONG_FORMAT)} to #{params[:dates].last.strftime(DateUtils::LONG_FORMAT)} #{am_pm_suffix}",
        attachments: self.attachments(params[:dates], params[:am], params[:pm]))
    else
      params[:webclient].chat_postEphemeral(
        user: params[:user],
        channel: params[:channel],
        text: ":thinking_face: Please use today, tomorrow, or any day of the week..."
      )
    end
  end

  def self.attachments dates, am, pm
    return [
      {
        "callback_id": "wfh_confirmation",
        "fallback": "Confirm",
        "attachment_type": "default",
        "actions":[
          {
            "name": "wfh_confirm",
            "text": "Confirm",
            "type": "button",
            "value": [dates, am, pm].flatten.to_json,
            "style": "primary"
          },
			    {
					  "name": "wfh_discard",
					  "text": "Discard",
					  "type": "button",
					  "style": "danger"
				  }
			  ]
	    }
	  ]
  end
end
