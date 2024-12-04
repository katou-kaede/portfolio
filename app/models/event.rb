class Event < ApplicationRecord
  belongs_to :user
  belongs_to :group, optional: true

  has_many :participants, dependent: :destroy
  has_many :users, through: :participants

  validates :name, presence: true
  validates :visibility, presence: true, inclusion: { in: %w[general limited] }
  validates :status, inclusion: { in: %w[open closed] }

  after_create :add_host_as_participant

  # イベントの主催者かどうかを判定する
  def hosted_by?(user)
    user.present? && self.user_id == user.id
  end

  # 募集を開始するメソッド
  def open_registration
    update(status: "open")
  end

  # 募集を終了するメソッド
  def close_registration
    update(status: "closed")
  end

  # 募集状態を更新するメソッド
  def update_registration_status
   # if date.past? || (capacity.present? && participants.count >= capacity)
   if date.past?
      close_registration
    else
      open_registration
    end
  end

  # 募集中かどうかを判定するメソッド
  def registration_open?
    return false if status == "closed"
    return false if date.past? # 過去のイベントは募集終了
    # return false if capacity.present? && participants.count >= capacity # 定員に達しているイベントは募集終了

    true # それ以外は募集中
  end

  def start_time
    self.date
  end

  scope :viewable_by, ->(user) {
    if user
      where(
        "visibility = 'general' OR
        (visibility = 'limited' AND (
          (group_id IS NULL AND EXISTS
            (SELECT 1 FROM friendships WHERE friend_id = ? AND user_id = events.user_id)) OR
          (group_id IS NOT NULL AND EXISTS
            (SELECT 1 FROM group_members WHERE user_id = ? AND group_id = events.group_id))
        )) OR
        (events.user_id = ?)", user.id, user.id, user.id
      )
    else
      where(visibility: "general")
    end
  }

  # 検索用スコープ（イベント名、場所、日付）
  scope :search, ->(params, user_id) {
    query = all
    if params[:search].present?
      query = query.where("name ILIKE ?", "%#{params[:search]}%")
    end
    if params[:location].present?
      query = query.where("location ILIKE ?", "%#{params[:location]}%")
    end
    if params[:date].present?
      query = query.where("DATE(date) = ?", params[:date])
    end
    query
  }

  # 参加中イベントのフィルタリング
  scope :participating, ->(user) {
    if user.present?
      joins(:participants).where("participants.user_id = ?", user.id)
    else
      none
    end
  }

  private

  def add_host_as_participant
    participants.create(user_id: user_id)
  end
end
