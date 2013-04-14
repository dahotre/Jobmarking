class Lookup
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :domain
  field :company
  field :title
  field :description
  field :location
  field :other_domain_hits, type: Integer
  field :is_deleted, type: Boolean
  field :destroy_notices, type: Array
  field :example_page
  
  before_save :lower_case_domain
  validates_uniqueness_of :domain
  validates_presence_of :example_page, :company, :title, :description, :location, :domain
  
  scope :active, where( domain: /[^(_d)]$/i )
  scope :inactive, where( domain: /[(_d)]$/i )
  
  protected
  def lower_case_domain
    self.domain.downcase!
  end
  
end
