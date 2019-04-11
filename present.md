# 1 - Attribute

```ruby
module RQL
  class Attribute < Struct.new(:relation, :name)
  end
end
```


# 2 - Table

```ruby
module RQL
  class Attribute < Struct.new(:relation, :name)
  end

  class Table
    attr_reader :name

    def initialize(name)
      @name = name
    end
  end
end
```


# 3 - Attribute Factory

```ruby
module RQL
  class Attribute < Struct.new(:relation, :name)
  end

  class Table
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def [](attribute)
      Attribute.new(name, attribute)
    end
  end
end
```


# 3 - Attribute Factory

```ruby
module RQL
  class Attribute < Struct.new(:relation, :name)
  end

  class Table
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def [](attribute)
      Attribute.new(name, attribute)
    end
  end
end
```

```ruby
users   = RQL::Table.new(:users)
user_id = users[:id]
```


# 4 - Projection

Why we use project instead of select

```ruby
users.project(:id, :name, :email)
```


# 5 - Nodes

```ruby
module RQL
  module Nodes
  end
end
```


# 5 - Nodes

```ruby
module RQL
  module Nodes
    SQLLiteral = Class.new(String)
  end
end
```


# 5 - Nodes

```ruby
module RQL
  module Nodes
    SQLLiteral = Class.new(String)
  end
end
```

```ruby
module RQL
  def self.sql(raw_sql)
    Nodes::SQLLiteral.new(raw_sql)
  end
end
```


# 5 - Nodes

```ruby
module RQL
  module Nodes
    SQLLiteral = Class.new(String)
  end
end
```

```ruby
module RQL
  def self.sql(raw_sql)
    Nodes::SQLLiteral.new(raw_sql)
  end

  def self.star
    sql "*"
  end
end
```

```ruby
users[RQL.star] => "users".*
```


# 5 - Nodes

```ruby
module RQL
  module Nodes
    SQLLiteral = Class.new(String)

    Unary = Struct.new(:expr)
    Binary = Struct.new(:left, :right)
    Nary = Class.new(Array)
  end
end
```


# 6 - Projection

```ruby
module RQL
  module Nodes
    SQLLiteral = Class.new(String)

    Unary = Struct.new(:expr)
    Binary = Struct.new(:left, :right)
    Nary = Class.new(Array)

    Projection = Class.new(Nary)
  end
end
```


# 7 - Tree

`RQL::Tree` represents the root node of the AST structure.

```ruby
module RQL
  class Tree
    attr_reader :table, :projections

    def initialize(table = nil)
      @table       = table
      @projections = Nodes::Projection.new
    end
  end
end
```


# 8 - Immutability

All mutations of the AST must be immutable

```ruby
module RQL
  class Tree
    attr_reader :table, :projections

    def initialize(table = nil)
      @table       = table
      @projections = Nodes::Projection.new
    end

    def initialize_copy(**options)
      new_table = options.fetch(:from) { table.dup }

      self.class.new(new_table).tap do |copy|
        copy.instance_variable_set :@projections, options.fetch(:projections) { projections.dup }
      end
    end
  end
end
```


# 8 - Immutability

project converts plan strings and symbols into Attribute objects

```ruby
module RQL
  class Tree
    attr_reader :table, :projections

    def initialize(table = nil)
      @table       = table
      @projections = Nodes::Projection.new
    end

    def initialize_copy(**options)
      new_table = options.fetch(:from) { table.dup }

      self.class.new(new_table).tap do |copy|
        copy.instance_variable_set :@projections, options.fetch(:projections) { projections.dup }
      end
    end

    def from(table)
      initalize_copy from: table
    end

    def project(*expr)
      initialize_copy projections: @projections.concat(
        Array(expr).map { |e|
          case e
          when String, Symbol
            table[e]
          else
            e
          end
        }
      )
    end
  end
end
```


# 9 - Select

Now we can have our Select node

```ruby
module RQL
  Select = Class.new(Tree)
end
```


# 10 - Table#project

Table#project is just a Select factory

```ruby
module RQL
  Select = Class.new(Tree)
end
```

```ruby
module RQL
  class Table < Struct.new(:name)
    def [](attribute)
      Attribute.new(name, attribute)
    end

    def project(*exprs)
      Select.new(self).project(*exprs)
    end
  end
end
```

```ruby
users = RQL::Table.new(:users).project(:id, :name, :email)
```


# 11 - Quoted

We need a node that acts like a quoted string value

```ruby
module RQL
  module Nodes
    Quoted = Class.new(Unary)
  end
end
```


# 11 - Quoted

We're going to use this a _lot_ so we'll build a helper method too.

```ruby
module RQL
  module Nodes
    Quoted = Class.new(Unary)

    def self.quoted(other)
      case other
      when Attribute, Table, Quoted, SQLLiteral
        other
      when Numeric
        SQLLiteral.new(other.to_s)
      else
        Quoted.new(other)
      end
    end
  end
end
```

```ruby
RQL::Nodes.quoted(users)        # => #<struct RQL::Table name=:users>
RQL::Nodes.quoted(users[:name]) # => #<struct RQL::Attribute relation=:users name=:name>
RQL::Nodes.quoted(123)          # => 123
RQL::Nodes.quoted("foo")        # => "'foo'"
```


# 12 - Equality

```ruby
module RQL
  module Nodes
    class Equality < ???
    end
  end
end
```


# 12 - Equality

An "infix" is any binary expression separated by an operator in the middle.

- 2 + 2
- 6 * 9
- 4 / 20

```ruby
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
```


# 12 - Equality

```ruby
module RQL
  module Nodes
    class InfixOperation < Binary
      attr_reader :operator

      def initialize(operator, left, right)
        @operator = operator
        super(left, right)
      end
    end

    class Equality < InfixOperation
      def initialize(left, right)
        super(:'=', left, right)
      end
    end
  end
end
```


# 12 - Equality

Thats... unwieldy.

```ruby
RQL::Nodes::Equality.new(users[:email], RQL::Nodes.quoted("john@example.com"))
```


# 12 - Equality

You practically never use Nodes directly.

```ruby
module RQL
  module Predications
    def eq(other)
      Nodes::Equality.new(self, Nodes.quoted(other))
    end
  end

  class Attribute < Struct.new(:relation, :name)
    include Predications
  end
end
```

```ruby
users[:email].eq("john@example.com")
```


# 13 - Where

Now that we have predicate expressions, we need a where clause to store them.


# 13 - Where

Where is just a Unary node!

```ruby
module RQL
  module Nodes
    class Where < Unary
    end
  end
end
```


# 13 - Where

😵  Where clauses seem complicated, but building them is very simple.

```ruby
module RQL
  module Nodes
    Grouping = Class.new(Unary)
    And      = Class.new(Binary)
    Or       = Class.new(Binary)

    class Where < Unary
      def and(other)
        if expr
          And.new(expr, Grouping.new(other))
        else
          other
        end
      end

      def or(other)
        if expr
          Or.new(expr, Grouping.new(other))
        else
          other
        end
      end
    end
  end
end
```


# 13 - Where

```ruby
module RQL
  class Tree
    attr_reader :projections, :wheres, :table

    def initialize(table = nil)
      @table       = table
      @projections = Nodes::Projection.new
      @wheres      = Nodes::Where.new
    end

    # ...

    def where(expr)
      initialize_copy wheres: @wheres.and(expr)
    end

    def or(expr)
      initialize_copy wheres: @wheres.or(expr)
    end
  end

  class Table < Struct.new(:name)
    # ...

    def where(expr)
      Select.new(self).where(expr)
    end
  end
end
```

```ruby
users = RQL::Table.new(:users)
users.where(users[:email].eq("john@example.com")).project(:id, :name, :email)
```

discard
(•_•)

( •_•)>⌐■-■

(⌐■_■)


# 14 - Visitor

We don't have the luxury of overloaded methods in Ruby, so we have to do our own dispatch.

```ruby
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
```

discard
- dispatch converts a class into a method name such as `visit\_RQL\_Nodes\_Attribute` and caches the result
- visit gets the method name and dispatches the arguments to that method


# 14 - Visitor

Our visit method needs two arguments:
- A node object
- a collector object to store the output

```ruby
module RQL
  module Visitors
    class SQLVisitor < Visitor
      def visit(object, collector = "")
        super(object, collector)
      end
    end
  end
end
```

discard
Our collector is just a string object. ¯\\\_(ツ)\_/¯


# 14 - Visitor

Each and every node in the graph gets its own visit method. This is where things get tedious.

```ruby
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
```

```sql
"users".*
"users"."email"
```


# 14 - Visitor

Each and every node in the graph gets its own visit method. This is where things get tedious.

```ruby
def visit_RQL_Table(object, collector)
  collector << quoted(object.name)
end
```

```sql
"users"
```


# 14 - Visitor

A visit method that received an object with sub-nodes visits them individually.

This is a depth-first algorithm. Every node will get visited this way 🙌

```ruby
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

def visit_RQL_Nodes_Where(object, collector)
  collector << " WHERE "
  visit object.expr, collector
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
```

discard
inject_join looks bad, just it's just visiting each expression inside projections separately and then joining them with a provided separator.


# 14 - Visitor

Since Equality is just an implementation of InfixOperator, it doesn't even need its own visit method.

Subclasses that don't need a different implmentation are just aliases

```ruby
def visit_RQL_Nodes_InfixOperation(object, collector)
  visit object.left, collector
  collector << " #{object.operator} "
  visit object.right, collector
end

alias visit_RQL_Nodes_Equality visit_RQL_Nodes_InfixOperation
```


# 14 - Visitor

Seriously, there are so many of these

```ruby
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
```


# 14 - Visitor

There's no magic here, visitors are really brute-force objects

```ruby
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
```


# 15 - Accept

In this pattern, the AST object implements accept that takes a visitor as an argument

```ruby
module RQL
  class Tree
    # ...

    def accept(visitor)
      visitor.visit(self)
    end
  end
end
```

```ruby
users   = RQL::Table.new(:users)
query   = users.where(users[:id].eq(100).or(users[:email].eq("john@example.com"))).project(:id, :name, :email)
visitor = RQL::Visitors::SQLVisitor.new

query.accept(visitor)
```


# 16 - The End

![](merge.png)

[Github: alassek/rql](https://github.com/alassek/rql)
