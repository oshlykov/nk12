class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    user ||= User.new # guest user (not logged in)
    user.role ||= 'guest'

    if user.role? :guest
      can :read, :all
    end

    if user.role? :auth
      can :new, Protocol
      can [:update, :destroy], Protocol do |p|
        p.priority >= 100 and p.user_id == user.id
      end
      can :destroy, Picture do |pic|
	user.id == (pic.folder ? pic.folder.created_by_id :
		    pic.protocol.user_id)
      end
      can [:edit, :destroy], Folder, :created_by_id => user.id
      can :unfold, Folder do |folder|
	folder.created_by_id == user.id or !folder.reserved?
      end
    end

    if user.role? :observer
      #can :update, Protocol, :active => true, :user_id => user.id
    end

    if user.role? :region
      #can :manage, 
      can [:destroy, :checking], Protocol
    end

    if user.role? :admin
      #can :update_role
      can :manage, :all
      #can :manage, Protocol
    end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end

end
