require 'digest/md5'
module ApplicationHelper

  def display_base_errors resource
    return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
    html = <<-HTML
    <div class="alert alert-error alert-block">
      <button type="button" class="close" data-dismiss="alert">&#215;</button>
      #{messages}
    </div>
    HTML
    html.html_safe
  end

  def gravatar_image(email, size=14)
    image_tag "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?d=mm&s=#{size}"
  end

end
