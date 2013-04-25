class HomeController < ApplicationController
  def index
    if params[:near].present?
      near_arr = params[:near].split(',')
      if ( near_arr.length == 2 && near_arr[0].numeric? && near_arr[1].numeric? )
        near_arr.map! {|l| l.to_f}
        @jobs = Job.active.page(params[:page]).near_to( near_arr )
      else
        geo_code_task = GeocodeTask.new params[:near]
        lnglat_arr = geo_code_task.perform
        if lnglat_arr.present?
          @jobs = Job.active.page(params[:page]).near_to( lnglat_arr )
        else
          @jobs = Job.active.page(params[:page])
        end
      end

    else
      @jobs = Job.active.page(params[:page])
    end

    @short_job = Job.new
  end
end
