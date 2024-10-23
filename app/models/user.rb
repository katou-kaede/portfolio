class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile

  has_many :events, dependent: :destroy

  # ユーザー作成後にプロフィールを作成
  # after_create :create_profile

  # private

  # def create_profile
    # Profile.create(user: self, name: self.profile_attributes[:name]) if self.profile_attributes.present?
  # end

  def update_without_current_password(params, *options)

    if params[:password].blank? && params[:password_confirmation].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
    end

    result = update_attributes(params, *options)
    clean_up_passwords
    result
  end
end
