module ApplicationHelper
  def suckerfish(node)
    fuc = lambda do |nodes|
      return "" if nodes.empty?
      return "<ul>" +
        nodes.inject("") do |string, (node, children)|
          string + "<li rel='#{node.id}'>" +
          node.name+
          fuc.call(children) +
          "</li>"
        end +
        "</ul>"
    end
    fuc.call(node.descendants.arrange)
  end

  def vds(i=0, election_id=1)
    VOTING_DICTIONARY_SHORT[election_id][i]
  end

  def social_enable
    return false if Rails.env.development?
    social_exclude = YAML::load <<SOCIAL_TEXT
folders:
  new:
  edit:
  index:
protocols:
  edit:
  show:
  checking:
  unfold:
SOCIAL_TEXT
    return false if social_exclude.include? controller.controller_name and social_exclude[controller.controller_name.to_s].include? controller.action_name
    true
  end
end
