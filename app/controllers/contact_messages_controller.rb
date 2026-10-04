class ContactMessagesController < ApplicationController
  rate_limit to: 5, within: 1.hour, only: :create,
    with: -> { redirect_to new_contact_message_path, alert: "Too many messages sent — please try again later." }

  def new
    @contact_message = ContactMessage.new
  end

  def create
    # Honeypot: real visitors never fill this hidden field. Pretend success
    # either way so bots can't tell they were caught.
    if params.dig(:contact_message, :nickname).present?
      return redirect_to new_contact_message_path, notice: "Thanks — we'll get back to you soon."
    end

    @contact_message = ContactMessage.new(contact_message_params)
    if @contact_message.save
      ContactMailer.new_message(@contact_message).deliver_later
      redirect_to new_contact_message_path, notice: "Thanks — we'll get back to you soon."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_message_params
    params.require(:contact_message).permit(:name, :email, :subject, :message)
  end
end
