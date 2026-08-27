class OrdersController < ApplicationController
  before_action :authenticate_user!, only: [ :index ]

  def index
    @orders = current_user.orders.recent.page(params[:page]).per(10)
  end

  def show
    @order = Order.find(params[:id])

    # Only allow viewing if it's the user's order or they're an admin
    unless @order.user == current_user || current_user&.admin?
      redirect_to root_path, alert: "You don't have permission to view this order."
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Order not found."
  end
end
