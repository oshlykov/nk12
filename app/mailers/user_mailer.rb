class UserMailer < ActionMailer::Base
  default :from => "kapuk@yandex.ru"
 
  def notify_admin(user)
    @user = user
    #@url  = "http://example.com/login"
    mail(:to => "info@kapuk.info", :subject => "Я буду наблюдателем —#{@user.email}", :reply => @user.email)
  end
end
