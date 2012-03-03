class PicturesController < InheritedResources::Base
  belongs_to :protocol, :folder, :polymorphic => true, :optional => true

  before_filter :auth, :except => [:index, :show, :create]

  def create
    if params.include? 'login' and params.include? 'password'
      #mobile upload
      if user = User.find_by_email(params['login'])
        unless user.authenticate(params['password'])
          render(:file => "public/403.html", :status => '207') and return 
        end

        params['picture'] = {"image" => params['file']}

        if user.commission and user.commission.is_uik
          if p = user.commission.protocols.where(:user_id => user.id).first
            params['protocol_id'] = p.id
          else
            p = user.commission.protocols.new
            p.user = user
            p.priority = user.commission.protocols.size + 100
            p.save
            params['protocol_id'] = p.id
          end
          params['commission_id'] = user.commission_id
        else
          # ИСПРАВИТЬ добавить сохранение неприкреплённых протоколов в Спецхран
          render :file => "public/404.html", :status => '208' and return
        end
      end
    end
    create! do |ok, nok|
      ok.js do
        render :json => resource.to_jq_upload, :content_type => 'text/html' 
      end
      nok.js do
        render :json => [{:error => "custom_failure"}], :status => 304 
      end
    end
  end

  def destroy
    raise 'Not authorized' unless can?(:destroy, resource)
    destroy! do |ok, nok|
      ok.js
    end
  end

  protected
  def create_resource pic
    pic.user = current_user
    pic.save
  end
end
