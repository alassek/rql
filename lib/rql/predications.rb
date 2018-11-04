module RQL
  module Predications
    def eq(other)
      Nodes::Equality.new self, Nodes.quoted(other)
    end
  end
end
