class Job
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :url
  field :title
  field :description
  field :location
  field :company
  
  field :actual_url
  field :active, type: Boolean, default: true
  
  belongs_to :user
  
  validates_presence_of :url, :actual_url
  validates_format_of :url, :actual_url, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
  
  scope :active, where( active: true )
  scope :inactive, where( active: false)
  
  scope :by_user, ->(curr_user) {
    where( user: curr_user )
  }
end
