# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def show
    page = params[:path]

    %w[application].each do |root_page|
      if page.match(%r{#{root_page}/?$})
        page = File.join(root_page, "index")
      end
    end

    if template_exists? page
      render template: page
    elsif template_exists? "application/#{page}"
      render template: "application/#{page}"
    else
      render file: "404.html", status: :not_found
    end
  end
end
