require_relative "predications"

module RQL
  module Nodes
    class Unary < Struct.new(:expr)
      include Predications
    end

    class Binary < Struct.new(:left, :right)
      include Predications
    end

    class Nary < Array
      include Predications
    end

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
