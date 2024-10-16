class Profile < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :bio, length: { maximum: 500 }
end
