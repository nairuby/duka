# == Schema Information
#
# Table name: contact_messages
#
#  id         :uuid             not null, primary key
#  email      :string           not null
#  message    :text             not null
#  name       :string           not null
#  status     :string           default("new"), not null
#  subject    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ContactMessage < ApplicationRecord
  STATUSES = %w[new read archived].freeze

  # Honeypot field for the contact form - not a real column. Real visitors
  # never see or fill it; see ContactMessagesController#create.
  attr_accessor :nickname

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true
  validates :status, inclusion: { in: STATUSES }
end
