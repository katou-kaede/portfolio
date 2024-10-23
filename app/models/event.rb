class Event < ApplicationRecord
  belongs_to :user
  validates :name, presence: true
  validates :visibility, presence: true, inclusion: { in: %w[general limited] }
end
