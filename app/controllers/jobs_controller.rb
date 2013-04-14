class JobsController < ApplicationController
  
  before_filter :authenticate_user!, :except => [:index, :show]
  
  # GET /jobs
  # GET /jobs.json
  def index
    @jobs = Job.by_user current_user

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @jobs }
    end
  end

  # GET /jobs/1
  # GET /jobs/1.json
  def show
    @job = Job.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @job }
    end
  end

  # GET /jobs/new
  # GET /jobs/new.json
  def new
    @job = Job.new
    @job.user=current_user
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @job }
    end
  end

  # GET /jobs/1/edit
  def edit
    debugger
    temp_job = Job.find(params[:id])
    
    if temp_job.user == current_user
      @job = temp_job
    else
      @job = Job.new
      @job.user = current_user
      
      logger.debug temp_job
      temp_job.attributes.each { |attr|
        logger.debug attr
        if attr[0].in? ['url', 'title', 'location', 'description', 'actual_url', 'company', 'active']
          @job.send( attr[0].to_s + '=', attr[1])
        end  
      }
    end
  end

  # POST /jobs
  # POST /jobs.json
  def create
    @job = Job.new(params[:job])
    
    unless @job.user == current_user
      @job.user = current_user
    end

    respond_to do |format|
      if @job.save
        format.html { redirect_to @job, notice: 'Job was successfully created.' }
        format.json { render json: @job, status: :created, location: @job }
      else
        format.html { render action: "new" }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /jobs/1
  # PUT /jobs/1.json
  def update
    debugger
    
    @job = Job.find(params[:id])

    unless @job.user == current_user
      @job = Job.new
      @job.user = current_user
      Job.find(params[:id]).attributes.each { |attr|
        if attr[0].in? ['url', 'title', 'location', 'description', 'actual_url', 'company', 'active']
          @job.send( attr[0].to_s + '=', attr[1])
        end  
      }
    end

    respond_to do |format|
      if @job.update_attributes(params[:job])
        format.html { redirect_to @job, notice: 'Job was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    @job = Job.find(params[:id])
    
    if @job.user == current_user
      @job.destroy
    end

    respond_to do |format|
      format.html { redirect_to jobs_url }
      format.json { head :no_content }
    end
  end
end
