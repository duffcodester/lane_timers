class ToolsController < ApplicationController
  skip_before_action :require_login, only: [:index]
  TOOLS_DIR = Rails.root.join("public", "tools")

  def index
    @files = Dir.exist?(TOOLS_DIR) ? Dir.children(TOOLS_DIR).sort : []
  end
end
