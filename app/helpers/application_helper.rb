module ApplicationHelper
  def age(birthday)
    return if birthday.blank?
    now = Time.zone.now
    now.year = birthday.year - ((now.month > birthday.month || (now.month == birthday.month && now.day >= birthday.day)) ? 0 : 1)
  end
end
