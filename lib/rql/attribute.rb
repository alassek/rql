require "rql/predications"

module RQL
  class Attribute < Struct.new(:relation, :name)
    include Predications
  end
end
