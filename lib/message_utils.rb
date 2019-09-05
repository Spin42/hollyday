class MessageUtils
  EMOJIS = {"wfh": ":house_with_garden:", "pto": ":palm_tree:", "sick": ":pill:"}

  def self.emoji_for entry_type
    EMOJIS[:"#{entry_type}"]
  end
end
