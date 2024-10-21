module ApplicationHelper
  def age(birthday)
    return if birthday.blank?

  now = Time.zone.now
  age = now.year - birthday.year
  age -= 1 if now.month < birthday.month || (now.month == birthday.month && now.day < birthday.day)
  age
  end
end
