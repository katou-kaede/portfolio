class Event < ApplicationRecord
  belongs_to :user

  has_many :participants, dependent: :destroy
  has_many :users, through: :participants

  validates :name, presence: true
  validates :visibility, presence: true, inclusion: { in: %w[general limited] }
  validates :status, inclusion: { in: %w[open closed] }

  after_create :add_host_as_participant

  # イベントの主催者かどうかを判定する
  def hosted_by?(user)
    self.user_id == user.id
  end

  # 募集を開始するメソッド
  def open_registration
    update(status: 'open')
  end

  # 募集を終了するメソッド
  def close_registration
    update(status: 'closed')
  end

  # 募集状態を更新するメソッド
  def update_registration_status
    if date.past? || (capacity.present? && participants.count >= capacity)
      close_registration
    else
      open_registration
    end
  end

  # 募集中かどうかを判定するメソッド
  def registration_open?
    return false if status == 'closed'
    return false if date.past? # 過去のイベントは募集終了
    return false if capacity.present? && participants.count >= capacity # 定員に達しているイベントは募集終了

    true # それ以外は募集中
  end

  private

  def add_host_as_participant
    participants.create(user_id: user_id)
  end
end
