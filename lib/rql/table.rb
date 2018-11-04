require "rql/attribute"

module RQL
  class Table < Struct.new(:name)
    def [](attribute)
      Attribute.new(self, attribute)
    end

    def where(expr)
      Select.new(self).where(expr)
    end

    def project(*exprs)
      Select.new(self).project(
        exprs.map { |e|
          case e
          when String, Symbol
            self[e]
          else
            e
          end
        }
      )
    end
  end
end
