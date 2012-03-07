Nkapp::Application.configure do
  config.action_mailer.smtp_settings = {
    :address              => "smtp.yandex.ru",
    :domain               => 'yandex.ru',
    :user_name            => 'kapuk@yandex.ru',
    :password             => 'rdfhntw',
    :authentication       => 'plain'}

end