require "rql/version"
require "rql/nodes"
require "rql/table"
require "rql/tree"
require "rql/visitors"
require "rql/predications"

module RQL
  Error  = Class.new(StandardError)
  Select = Class.new(Tree)

  def self.sql(raw_sql)
    Nodes::SQLLiteral.new(raw_sql)
  end

  def self.star
    sql "*"
  end
end
