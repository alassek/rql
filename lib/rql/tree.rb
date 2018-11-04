module RQL
  class Tree
    attr_reader :projections, :wheres, :table

    def initialize(table = nil)
      @table       = table
      @projections = Nodes::Projection.new
      @wheres      = Nodes::Where.new
    end

    def initialize_copy(**options)
      new_table = options.fetch(:from, table)

      self.class.new(new_table).tap do |copy|
        copy.instance_variable_set :@projections, options.fetch(:projections, projections)
        copy.instance_variable_set :@wheres, options.fetch(:wheres, wheres)
      end
    end

    def from(table)
      initialize_copy(from: table)
    end

    def project(expr)
      initialize_copy projections: @projections.concat(Array(expr))
    end

    def where(expr)
      initialize_copy wheres: @wheres.and(expr)
    end

    def or(expr)
      initialize_copy wheres: @wheres.or(expr)
    end
  end
end
