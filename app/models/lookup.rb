class Lookup
  include Mongoid::Document
  field :domain, type: String
  field :company, type: String
  field :title, type: String
  field :description, type: String
  field :location, type: String
  field :other_domain_hits, type: Integer
  field :is_deleted, type: Boolean
  field :destroy_notices, type: Array
  field :example_page, type: String
  
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
