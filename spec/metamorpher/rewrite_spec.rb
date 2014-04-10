require "metamorpher/rule"
require "metamorpher/node"
require "metamorpher/variable"

require "parser/current"
require "unparser"

module Metamorpher
  describe Node do
    describe "simple" do
      it "nodes should match asts" do
        a = Node.new(type: :send, children: [Node.new(type: nil), Node.new(type: :a)])
        b = Node.new(type: :send, children: [Node.new(type: nil), Node.new(type: :b)])
        op = Node.new(type: :^)

        pattern = Node.new(type: :send, children: [a, op, b])

        ast = parse("a ^ b")
        result = pattern.match(ast)

        expect(result.matches?).to be_true
      end

      it "nodes should return a negative result when there is no match" do
        a = Node.new(type: :send, children: [Node.new(type: nil), Node.new(type: :a)])
        b = Node.new(type: :send, children: [Node.new(type: nil), Node.new(type: :b)])
        op = Node.new(type: :^)

        pattern = Node.new(type: :send, children: [a, op, b])

        ast = parse("a + b")
        result = pattern.match(ast)

        expect(result.matches?).to be_false
      end

      it "variables should capture the nodes that they match" do
        x = Variable.new(name: :x)
        y = Variable.new(name: :y)
        op = Node.new(type: :^)

        pattern = Node.new(type: :send, children: [x, op, y])

        ast = parse("a ^ b")
        result = pattern.match(ast)

        expect(result.matches?).to be_true
        expect(result.match_for(x)).to eq(ast.children.first)
        expect(result.match_for(y)).to eq(ast.children.last)
      end
    end

    describe "rule" do
      it "should rewrite top-level term" do
        x = Variable.new(name: :x)
        y = Variable.new(name: :y)
        pattern = Node.new(type: :send, children: [x, Node.new(type: :^), y])
        replacement = Node.new(type: :send, children: [x, Node.new(type: :+), y])
        rule = Rule.new(pattern: pattern, replacement: replacement)

        ast = parse("a ^ b")
        rewritten = rule.apply(ast)

        expect(rewritten).to eq(parse("a + b"))
      end

      it "should rewrite a nested term" do
        x = Variable.new(name: :x)
        y = Variable.new(name: :y)
        pattern = Node.new(type: :send, children: [x, Node.new(type: :^), y])
        replacement = Node.new(type: :send, children: [x, Node.new(type: :+), y])
        rule = Rule.new(pattern: pattern, replacement: replacement)

        ast = parse("def foo; a ^ b; end")
        rewritten = rule.apply(ast)

        expect(rewritten).to eq(parse("def foo; a + b; end"))
      end

      it "should be able to rewrite User.where(username: username).first" do
        ast = parse("User.where(username: username).first")

        # TYPE.where(PARAMS).first -> TYPE.find_by(PARAMS)
        # send(send(TYPE, where, PARAMS), first) -> send(TYPE, find_by, PARAMS)

        pattern = Node.new(
          type: :send,
          children: [
            Node.new(
              type: :send,
              children: [
                Variable.new(name: :type),
                Node.new(type: :where),
                Variable.new(name: :params)
              ]
            ),
            Node.new(
              type: :first
            )
          ]
        )

        replacement = Node.new(
          type: :send,
          children: [
            Variable.new(name: :type),
            Node.new(type: :find_by),
            Variable.new(name: :params)
          ]
        )

        rule = Rule.new(pattern: pattern, replacement: replacement)
        rewritten = rule.apply(ast)

        expect(rewritten).to eq(parse("User.find_by(username: username)"))
      end
    end

    def rewrite(code, rule)
      unparse(rule.apply(parse(code)))
    end

    def parse(source)
      import(Parser::CurrentRuby.parse(source))
    end

    def unparse(ast)
      Unparser.unparse(ast)
    end

    def import(ast)
      if ast.respond_to? :type
        Node.new(type: ast.type, children: ast.children.map { |c| import(c) })
      else
        Node.new(type: ast)
      end
    end
  end
end
