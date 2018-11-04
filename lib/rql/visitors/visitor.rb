module RQL
  module Visitors
    class Visitor
      def visit(object, *args)
        visit_method = dispatch[object.class]

        send visit_method, object, *args
      end

      private

      def dispatch
        @_dispatch ||= Hash.new do |hash, klass|
          hash[klass] = "visit_#{klass.name.gsub('::', '_')}"
        end
      end
    end
  end
end
