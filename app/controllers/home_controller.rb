class HomeController < ApplicationController
  def index
    @jobs = Job.active
    @short_job = Job.new
  end
end
