require "rql/attribute"

module RQL
  class Table
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def [](attribute)
      Attribute.new(name, attribute)
    end

    def where(expr)
      Select.new(self).where(expr)
    end

    def project(*exprs)
      Select.new(self).project(*exprs)
    end
  end
end
