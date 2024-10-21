class Profile < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :bio, length: { maximum: 500 }

  before_create :set_default_avatar

  private

  def set_default_avatar
    self.avatar = "default_avatar.png"
  end
end
