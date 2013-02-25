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
 def wicked_pdf_image_tag_for_public(img, options={})
    if img[0] == "/"
      new_image = img.slice(1..-1)
      image_tag "file://#{Rails.root.join('public', new_image)}", options
    else
      image_tag "file://#{Rails.root.join('public', 'images', img)}", options
    end
  end

end
