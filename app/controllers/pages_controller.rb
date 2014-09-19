class PagesController < ApplicationController
  def home
  	if !user_signed_in?
  		redirect_to new_user_session_path, notice: 'You must be logged in'
  	end
  end
end
