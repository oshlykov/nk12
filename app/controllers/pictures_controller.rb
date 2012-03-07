class PicturesController < InheritedResources::Base
  belongs_to :protocol, :folder, :polymorphic => true, :optional => true

  before_filter :auth, :except => [:index, :show, :create]

  def create
    if params.include? 'login' and params.include? 'password'
      #mobile upload
      if user = User.find_by_email(params['login'])
        unless user.authenticate(params['password'])
          render(:nothing => true, :status => '207') and return 
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
          render :nothing => true, :status => '208' and return
        end
      end
    end

    if params['picture']
      params['picture']['original_filename'] = params['picture']['image'].original_filename
      #Rails.logger.debug params['picture']['image'].original_filename
    end

    create! do |ok, nok|
      ok.html do
	render :partial => 'picture', :object => resource
      end
      nok.html do
        render :text => 'Ошибка при загрузке файла'
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
