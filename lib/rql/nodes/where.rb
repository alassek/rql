require "rql/nodes"

module RQL
  module Nodes
    class Where < Unary
      def and(other)
        self.class.new expr ? And.new(expr, other) : other
      end

      def or(other)
        self.class.new expr ? Or.new(expr, other) : other
      end
    end
  end
end
