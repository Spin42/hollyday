class Entry < ActiveRecord::Base
  validate :end_date_after_start_date

  AVAILABLE_TYPES = ["wfh", "pto", "sick", "afk"]

  belongs_to :team
  belongs_to :user

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end
end
