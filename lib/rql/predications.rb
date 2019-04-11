module RQL
  module Predications
    def eq(other)
      Nodes::Equality.new self, Nodes.quoted(other)
    end

    def and(other)
      Nodes::And.new self, other
    end

    def or(other)
      Nodes::Or.new self, other
    end
  end
end
