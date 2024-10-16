class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile, dependent: :destroy
  # accepts_nested_attributes_for :profile

  # ユーザー作成後にプロフィールを作成
  after_create :create_profile

  private

  def create_profile
    Profile.create(user: self)
  end
end
