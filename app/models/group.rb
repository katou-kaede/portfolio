class Group < ApplicationRecord
  belongs_to :user # グループの作成者
  has_many :group_members, dependent: :destroy
  has_many :members, through: :group_members, source: :user # グループのメンバー（友達）

  before_destroy :remove_group_from_events

  validates :name, presence: true

  private

  def remove_group_from_events
    Event.where(group_id: id).update_all(group_id: nil)
  end
end
