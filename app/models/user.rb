class User < ActiveRecord::Base
  has_secure_password

  validates :email, presence: true, format: { with: /\A.+@.+$\Z/ }, uniqueness: true
  validates :name, presence: true
  validates :country_code, presence: true
  validates :phone_number, presence: true, uniqueness: true
  validates_length_of :password, in: 6..20, on: :create

  has_many :vacation_properties
  has_many :reservations, through: :vacation_properties

  def send_message_via_sms(message)
    client = Twilio::REST::Client.new(
      ENV['ACc420224fc3cc8bb1e73d3e904b040d6b'],
      ENV['7b7079929c71e93b0536961babea03cd']
    )

    client.messages.create(
      from: ENV['16082086138'],
      to: full_number,
      body: message
    )
  end

  def check_for_reservations_pending
    pending_reservation.notify_host(true) if pending_reservation
  end

  def full_number
    country_code_number = country_code.gsub('+', '')
    "+#{country_code_number}#{phone_number}"
  end

  def pending_reservation
    reservations.where(status: "pending").first
  end

  def pending_reservations
    reservations.where(status: "pending")
  end
end
