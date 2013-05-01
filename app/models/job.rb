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

  field :geo_code, type: Array

  belongs_to :user
  
  validates_presence_of :url
  validates_format_of :url, :actual_url, :logo,
                      :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix

  scope :active, where( active: true, inherited:false )
  scope :inactive, where( active: false)
  
  scope :by_user, ->(curr_user) {
    where( user: curr_user )
  }

  scope :near_to, ->(param) {
    within_spherical_circle(geo_code: [param, (250.0/3959.0).to_f ])
  }

  def geocode_location
    Rails.logger.info 'Before saving job'
    if(self.location.present? && self.geo_code.blank?)
      geo_task = GeocodeTask.new self
      self.geo_code= geo_task.perform
    else
      Longo.create(reason: 'Location not found', job: self.attributes)
    end

  end
end
