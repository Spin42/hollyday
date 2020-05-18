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
        text: self.text_for_entry(dates, am_pm_suffix, params[:recurring]),
        attachments: self.attachments(dates, params[:am], params[:pm], params[:recurring]))
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
        attachments: self.attachments(params[:dates], params[:am], params[:pm], params[:recurring]))
    else
      params[:webclient].chat_postEphemeral(
        user: params[:user],
        channel: params[:channel],
        text: ":thinking_face: Please use today, tomorrow, or any day of the week..."
      )
    end
  end

  def self.text_for_entry dates, am_pm_suffix, recurring
    if recurring
      "You're working from home every #{dates.first.strftime("%A")}s #{am_pm_suffix} (will repeat for 12 weeks)"
    else
      "You're working from home on #{dates.first.strftime(DateUtils::LONG_FORMAT)} #{am_pm_suffix}"
    end
  end

  def self.attachments dates, am, pm, recurring
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
            "value": [dates, am, pm, recurring].flatten.to_json,
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
