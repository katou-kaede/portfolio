class Group < ApplicationRecord
  belongs_to :user # グループの作成者
  has_many :group_members, dependent: :destroy
  has_many :members, through: :group_members, source: :user # グループのメンバー（友達）

  validates :name, presence: true
end
