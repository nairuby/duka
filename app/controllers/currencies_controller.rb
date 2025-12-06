class CurrenciesController < ApplicationController
  def update
    if %w[KES USD].include?(params[:currency])
      session[:currency] = params[:currency]
    end
    
    redirect_back(fallback_location: root_path)
  end
end
