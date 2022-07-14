class StaticController < ActionController::Base
  def index
    # render file: 'public/build/index.html'
    render :file => "#{Rails.root}/public/index.html"
  end

end
