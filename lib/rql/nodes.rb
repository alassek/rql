module RQL
  module Nodes
    Unary  = Struct.new(:expr)
    Binary = Struct.new(:left, :right)
    Nary   = Class.new(Array)

    Grouping   = Class.new(Unary)
    And        = Class.new(Binary)
    Or         = Class.new(Binary)
    Projection = Class.new(Nary)

    SQLLiteral = Class.new(String)
  end
end

require_relative "nodes/equality"
require_relative "nodes/infix_operation"
require_relative "nodes/quoted"
require_relative "nodes/where"
