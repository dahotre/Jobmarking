class HomeController < ApplicationController
  def index
    @jobs = Job.active.page params[:page]
    @short_job = Job.new
  end
end
