class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile

  # 主催イベント
  has_many :events

  # 参加イベント
  has_many :participants
  has_many :participated_events, through: :participants, source: :event

  # 自分が友達として追加した関係
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships, source: :friend

  # 自分を友達として追加した関係
  has_many :inverse_friendships, class_name: 'Friendship', foreign_key: 'friend_id', dependent: :destroy
  has_many :inverse_friends, through: :inverse_friendships, source: :user

  has_many :group_members, foreign_key: :user_id
  has_many :groups, through: :group_members
  has_many :joined_groups, through: :group_members, source: :group

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

  # ユーザーがイベントに参加しているか確認するメソッド
  def participating?(event)
    event.participants.exists?(user_id: self.id)
  end

  # ユーザーがイベントに参加するメソッド
  def join_event(event)
    event.participants.create(user_id: self.id)
  end

  # ユーザーがイベントから離れるメソッド
  def leave_event(event)
    event.participants.where(user_id: self.id).destroy_all
  end

  # 他のユーザーと友達かどうかを判定するメソッド
  def friends_with?(other_user)
    friends.exists?(other_user.id)
  end

  # フォローするメソッド
  def follow(other_user)
    friendships.create(friend_id: other_user.id)
  end

  # フォロー解除するメソッド
  def unfollow(other_user)
    friendships.find_by(friend_id: other_user.id)&.destroy
  end
end
