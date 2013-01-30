module ApplicationHelper
  def error_messages_for(object)
    if object.errors.full_messages.size > 0
      content = ""
      content << content_tag(:h2, "Please try again")
      content << content_tag(:p, "There were problems with the following fields:")
      li_content = ""
      object.errors.full_messages.each do |msg|
        li_content << content_tag(:li, msg, nil, false)
      end

      content << content_tag(:ul, li_content, nil, false)
      content_tag(:div, content, {:id => "errorExplanation", :class => "errorExplanation"}, false)
    else
      ""
    end
  end

  def logo_tag(url)
    url ||= image_path('no-logo.png')
    image_tag url, :size => "100x100"
  end

  def page_header(header)
    content_for(:title, header)
    content_tag(:h1, header)
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end
end
