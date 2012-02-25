class ElectionsController < InheritedResources::Base
  def region_list
    render :partial => 'region_opt', :collection => resource.commissions.roots
  end
end
