class HomeController < ApplicationController
  def index
    @jobs = Job.active
  end
end
