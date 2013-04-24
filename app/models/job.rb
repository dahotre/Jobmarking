class Job
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :url
  field :title
  field :description
  field :location
  field :company
  field :logo
  
  field :actual_url
  field :active, type: Boolean, default: true
  field :inherited, type: Boolean, default: false

  field :note

  field :geo_code, type: LatLng

  belongs_to :user
  
  validates_presence_of :url
  validates_format_of :url, :actual_url, :logo,
                      :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
  before_save :geocode_location
  
  scope :active, where( active: true, inherited:false )
  scope :inactive, where( active: false)
  
  scope :by_user, ->(curr_user) {
    where( user: curr_user )
  }

  protected
  def geocode_location
    Rails.logger.info 'Before saving job'
    geo_task = GeocodeTask.new self
    geo_task.perform
  end
end
