require "rql/visitors/visitor"

module RQL
  module Visitors
    class SQLVisitor < Visitor
      def visit(object, collector = "")
        super(object, collector)
      end

      private

      def visit_RQL_Attribute(object, collector)
        collector << quoted(object.relation)
        collector << "."
        collector <<
          case object.name
          when Nodes::SQLLiteral
            object.name
          else
            quoted(object.name)
          end
      end

      def visit_RQL_Select(object, collector)
        collector << "SELECT "
        inject_join object.projections, collector, ", "
        collector << " FROM "
        visit object.table, collector
        visit object.wheres, collector
      end

      def visit_RQL_Table(object, collector)
        collector << quoted(object.name)
      end

      def visit_RQL_Nodes_InfixOperation(object, collector)
        visit object.left, collector
        collector << " #{object.operator} "
        visit object.right, collector
      end
      alias visit_RQL_Nodes_Equality visit_RQL_Nodes_InfixOperation

      def visit_RQL_Nodes_SQLLiteral(object, collector)
        collector << object
      end

      def visit_RQL_Nodes_Quoted(object, collector)
        collector << "'#{object.expr}'"
      end

      def visit_RQL_Nodes_Where(object, collector)
        collector << " WHERE "
        visit object.expr, collector
      end

      def visit_RQL_Nodes_Grouping(object, collector)
        collector << "("
        visit object.expr, collector
        collector << ")"
      end

      def visit_RQL_Nodes_And(object, collector)
        visit object.left, collector
        collector << " AND "
        visit object.right, collector
      end

      def visit_RQL_Nodes_Or(object, collector)
        visit object.left, collector
        collector << " OR "
        visit object.right, collector
      end

      def quoted(object)
        object.to_s.inspect
      end

      def inject_join(list, collector, join_str)
        len = list.length - 1
        list.each_with_index.inject(collector) do |c, (o, i)|
          if i == len
            visit o, c
          else
            visit(o, c) << join_str
          end
        end
      end
    end
  end
end
