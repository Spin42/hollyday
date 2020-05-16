class MessageUtils
  EMOJIS = {"wfh": ":house_with_garden:", "pto": ":palm_tree:", "sick": ":pill:"}

  def self.emoji_for entry_type
    EMOJIS[:"#{entry_type}"]
  end

  def self.am_pm_helper entry
    if entry.am && !entry.pm
      "AM"
    elsif !entry.am && entry.pm
      "PM"
    end
  end
end
