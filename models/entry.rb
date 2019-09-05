class Entry < ActiveRecord::Base
  AVAILABLE_TYPES = ["wfh", "pto", "sick"]

  belongs_to :team
  belongs_to :user
end
