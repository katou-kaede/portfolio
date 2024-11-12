class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User"

  validate :cannot_be_self_friend

  private

   # ユーザーが自分自身を友達として追加しないようにする
   def cannot_be_self_friend
    if user == friend
      errors.add(:friend, "は自分自身を友達として追加できません")
    end
  end
end
