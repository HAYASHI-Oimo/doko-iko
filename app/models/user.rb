class User < ApplicationRecord
    validates :name,
      presence: true,
      length: { maximum: 20 }

    validates :email,
      presence: true,
      confirmation: true,
      length: { maximum: 50 }

    validates :crypted_password,
      presence: true,
      length: { in: 6..20 }

    validates :children_count,
      presence: true,
      numericality: { only_integer: true },
      inclusion: { in: 1..5 }
end
