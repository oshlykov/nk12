class UserMailer < ActionMailer::Base
  default :from => "kapuk@yandex.ru"
 
  def notify_admin(user)
    @user = user
    #@url  = "http://example.com/login"
    mail(:to => "info@kapuk.info", :subject => "Я буду наблюдателем —#{@user.email}", :reply => @user.email)
  end

  def password_reset(user)
    @user = user
    mail :to => user.email, :subject => "Восстановление пароля"
  end
end
