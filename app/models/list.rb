class List < ApplicationRecord
  has_many :tags, dependent: :destroy
  attachment :image
end
