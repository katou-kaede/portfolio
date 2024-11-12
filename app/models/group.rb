class Group < ApplicationRecord
  belongs_to :user # グループの作成者
  has_many :group_members, dependent: :destroy
  has_many :members, through: :group_members, source: :user # グループのメンバー（友達）

  before_destroy :remove_group_from_events

  validates :name, presence: true

  # グループメンバー追加メソッド
  def add_member(user)
    unless members.include?(user)
      group_members.create(user: user)
    end
  end

  private

  def remove_group_from_events
    Event.where(group_id: id).update_all(group_id: nil)
  end
end
