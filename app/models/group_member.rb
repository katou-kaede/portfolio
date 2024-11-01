class GroupMember < ApplicationRecord
  belongs_to :group
  belongs_to :user # グループメンバーのユーザー（友達）
end
