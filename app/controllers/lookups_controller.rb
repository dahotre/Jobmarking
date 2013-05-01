class LookupsController < ApplicationController
  # GET /lookups
  # GET /lookups.json
  def index
    @lookups = Lookup.active

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lookups }
    end
  end

  # GET /lookups/1
  # GET /lookups/1.json
  def show
    @lookup = Lookup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @lookup }
    end
  end

  # GET /lookups/new
  # GET /lookups/new.json
  def new
    @lookup = Lookup.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @lookup }
    end
  end

  # GET /lookups/1/edit
  def edit
    @lookup = Lookup.find(params[:id])
  end

  # POST /lookups
  # POST /lookups.json
  def create
    @lookup = Lookup.new(params[:lookup])

    if (params[:preview])
      @job_params_hash = generate_job_params(@lookup)

      @lookup.example_page = @job_params_hash[:actual_url]

      @all_values_present = all_values_present?(@job_params_hash)

      respond_to do |format|
        format.html { render action: "new"}
        format.json { render json: @job_params_hash.merge( success: @all_values_present )}
      end

    elsif (params[:submit])
      respond_to do |format|
        if @lookup.save
          format.html { redirect_to @lookup, notice: 'Lookup was successfully created.' }
          format.json { render json: @lookup, status: :created, location: @lookup }
        else
          format.html { render action: "new" }
          format.json { render json: @lookup.errors, status: :unprocessable_entity }
        end
      end

    elsif (params[:unparseable])
      respond_to do |format|
        old_longo = Longo.find_by(:url => @lookup.example_page, :reason => 'Failed XPath parse')

        if old_longo.blank?
          Longo.create(:level => 'WARN', :reason => 'Failed XPath parse', :lookup => @lookup.attributes, :url => @lookup.example_page)
        end

        format.html { redirect_to lookups_path, notice: 'Issue reported. Thanks for the help!'}
      end
    end


  end

  # PUT /lookups/1
  # PUT /lookups/1.json
  def update
    @lookup = Lookup.find(params[:id])

    if (params[:preview])
      @lookup.assign_attributes params[:lookup]
      @job_params_hash = generate_job_params(@lookup)

      @lookup.example_page = @job_params_hash[:actual_url]

      @all_values_present = all_values_present?(@job_params_hash)

      respond_to do |format|
        format.html { render action: "new"}
        format.json { render json: @job_params_hash.merge( success: @all_values_present)}
      end

    else

      respond_to do |format|
        if @lookup.update_attributes(params[:lookup])
          format.html { redirect_to @lookup, notice: 'Lookup was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @lookup.errors, status: :unprocessable_entity }
        end
      end
    end

  end

  # DELETE /lookups/1
  # DELETE /lookups/1.json
  def destroy
    @lookup = Lookup.find(params[:id])
    if @lookup.example_page && @lookup.domain
      @lookup.domain += '_d'
      @lookup.is_deleted = true
      @lookup.save
    else
      @lookup.destroy
    end

    respond_to do |format|
      format.html { redirect_to lookups_url }
      format.json { head :no_content }
    end
  end

  protected
  def all_values_present?(job_params_hash)
    all_values_present = job_params_hash.reduce (true) { |memo, (k, v)|
      if [:logo, :company].include? k
        memo && true
      else
        memo && v.present?
      end
    }

    return all_values_present
  end

  def generate_job_params(lookup)
    parser = JobUrlParser.new(lookup.example_page)
    return parser.generate_params_given_lookup lookup
  end


end
