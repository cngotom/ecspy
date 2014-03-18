require 'utils/email'
class RegistrationsController < Devise::RegistrationsController

  private

  def after_inactive_sign_up_path_for(resource)
  	flash[:notice] = 'an confimation email has send to your email address :' + resource.email + '<br>'

  	flash[:notice] += 'please click the link to confimation'

  	email_link =Utils::Email.get_email_link(resource.email)

  	flash[:notice] += "<a class='btn' href='#{email_link}'> view  <a/>"

  	flash[:notice] = flash[:notice].html_safe
    new_user_session_path
  end
end