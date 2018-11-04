require "rql/nodes"

module RQL
  module Nodes
    class InfixOperation < Binary
      attr_reader :operator

      def initialize(operator, left, right)
        @operator = operator
        super(left, right)
      end
    end
  end
end
