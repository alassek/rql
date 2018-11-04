require "rql/attribute"
require "rql/table"
require "rql/nodes"

module RQL
  module Nodes
    Quoted = Class.new(Unary)

    def self.quoted(other)
      case other
      when Attribute, Table, Quoted, SQLLiteral
        other
      when Numeric
        SQLLiteral.new(other.to_s)
      else
        Quoted.new(other)
      end
    end
  end
end
