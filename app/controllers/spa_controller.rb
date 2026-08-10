# Serves the built Vue app. In production the SPA is copied into public/ so
# Rails and the interface deploy as one thing.
class SpaController < ActionController::Base
  def index
    index = Rails.public_path.join("index.html")

    if index.exist?
      render html: index.read.html_safe, layout: false
    else
      render json: { error: "SPA not built. Run `npm run build` in frontend/." },
             status: :not_found
    end
  end
end
