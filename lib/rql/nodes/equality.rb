require "rql/nodes/infix_operation"

module RQL
  module Nodes
    class Equality < InfixOperation
      def initialize(left, right)
        super(:'=', left, right)
      end
    end
  end
end
