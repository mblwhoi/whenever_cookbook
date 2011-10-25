def initialize(*args)
  super
  @action = :create
end

actions :create, :delete

attribute :name, :kind_of => String, :name_attribute => true, :required => true, :regex => /^[^\/]+$/
attribute :description, :kind_of => String
attribute :every, :kind_of => String
attribute :at, :kind_of => String
attribute :user, :kind_of => String
attribute :command, :kind_of => String
