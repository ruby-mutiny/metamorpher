# Based on http://blog.rubybestpractices.com/posts/aaronp/001_double_dispatch_dance.html

module Metamorpher
  module Visitable
    class Visitor
      ###
      # This method will examine the class and ancestors of +thing+. For each
      # class in the "ancestors" list, it will check to see if the visitor knows
      # how to handle that particular class. If it can't find a handler for the
      # +thing+ it will raise an exception.
      def visit(thing)
        thing.class.ancestors.each do |ancestor|
          method_name = :"visit_#{ancestor.name.split("::").last.downcase}"
          return send(method_name, thing) if respond_to?(method_name)
        end

        fail ArgumentError, "Can't visit #{thing.class}"
      end
    end
  end
end
