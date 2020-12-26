class PurchasesController < ApplicationController
  before_action :authenticate_user!

  def new
    @workshop_id = params[:workshop_id]
    @workshop = Workshop.find(@workshop_id)
    render layout: 'checkout'
  end


  def create
    @workshop_id = params[:workshop_id]
    @workshop = Workshop.find(@workshop_id)
    amount = (100 * @workshop.cost).to_i


    begin

      if Rails.env.development?
        t = 'tok_visa'
      else
        t = params[:stripeToken]
      end

      # Check if customer exists in Stripe (start)
      customer = if current_user.stripe_id?
                   Stripe::Customer.retrieve(current_user.stripe_id)
                 else
                   Stripe::Customer.create(
                     :email => current_user.email,
                     :source => t,
                   )
                 end
      # Check if customer exists in Stripe (end)

      payment_info = {
        stripe_id: customer.id,
      }


      current_user.update(payment_info)


      charge = Stripe::Charge.create(
        :amount => amount,
        :description => @workshop.title.to_s,
        :currency => 'usd',
        :customer => customer.id
      )
      create_charge = Charge.create user_id: current_user.id, stripe_charge_id: charge.id, amount: @workshop.cost.to_f
      create_enrollment = Enrollment.create user_id: current_user.id, workshop_id: @workshop.id


      redirect_to payment_complete_path, notice: 'Your payment is complete.'


    rescue => exception
      redirect_to root_path, notice: 'Your payment cannot be processed.'
    end


  end


  def payment_complete
  end

end
