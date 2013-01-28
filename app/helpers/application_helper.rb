module ApplicationHelper
  def is_active?(controller_action)
    controller = controller_action.split("#")[0]
    action = controller_action.split("#")[1]
    if request[:controller] == controller &&  ["*", request[:action]].include?(action)
      "active"
    else
      ""
    end
  end


end
