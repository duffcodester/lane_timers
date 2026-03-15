class PagesController < ApplicationController
  skip_before_action :require_login, only: [:readme]

  def readme
  end
end
