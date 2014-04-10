require "metamorpher/rule"
require "metamorpher/node"
require "metamorpher/variable"
require "metamorpher/greedy_variable"
require "metamorpher/derived"

require "parser/current"

module Metamorpher
  describe Node do
    describe "simple" do
      it "nodes should match asts" do
        a = Node.new(name: :send, children: [Node.new(name: nil), Node.new(name: :a)])
        b = Node.new(name: :send, children: [Node.new(name: nil), Node.new(name: :b)])
        op = Node.new(name: :^)

        pattern = Node.new(name: :send, children: [a, op, b])

        ast = parse("a ^ b")
        result = pattern.match(ast)

        expect(result.matches?).to be_true
      end

      it "nodes should return a negative result when there is no match" do
        a = Node.new(name: :send, children: [Node.new(name: nil), Node.new(name: :a)])
        b = Node.new(name: :send, children: [Node.new(name: nil), Node.new(name: :b)])
        op = Node.new(name: :^)

        pattern = Node.new(name: :send, children: [a, op, b])

        ast = parse("a + b")
        result = pattern.match(ast)

        expect(result.matches?).to be_false
      end

      it "variables should capture the nodes that they match" do
        x = Variable.new(name: :x)
        y = Variable.new(name: :y)
        op = Node.new(name: :^)

        pattern = Node.new(name: :send, children: [x, op, y])

        ast = parse("a ^ b")
        result = pattern.match(ast)

        expect(result.matches?).to be_true
        expect(result.match_for(x)).to eq(ast.children.first)
        expect(result.match_for(y)).to eq(ast.children.last)
      end

      it "should capture all remaining children" do
        name = Variable.new(name: :name)
        method = Node.new(name: :find_by_name_and_birthday)
        params = GreedyVariable.new(name: :params)

        pattern = Node.new(name: :send, children: [name, method, params])

        ast = parse("Person.find_by_name_and_birthday(name, birthday)")
        result = pattern.match(ast)

        expect(result.matches?).to be_true
        expect(result.match_for(params)).to eq(ast.children[2..3])
      end
    end

    describe "rule" do
      it "should rewrite top-level term" do
        x = Variable.new(name: :x)
        y = Variable.new(name: :y)
        pattern = Node.new(name: :send, children: [x, Node.new(name: :^), y])
        replacement = Node.new(name: :send, children: [x, Node.new(name: :+), y])
        rule = Rule.new(pattern: pattern, replacement: replacement)

        ast = parse("a ^ b")
        rewritten = rule.apply(ast)

        expect(rewritten).to eq(parse("a + b"))
      end

      it "should rewrite a nested term" do
        x = Variable.new(name: :x)
        y = Variable.new(name: :y)
        pattern = Node.new(name: :send, children: [x, Node.new(name: :^), y])
        replacement = Node.new(name: :send, children: [x, Node.new(name: :+), y])
        rule = Rule.new(pattern: pattern, replacement: replacement)

        ast = parse("def foo; a ^ b; end")
        rewritten = rule.apply(ast)

        expect(rewritten).to eq(parse("def foo; a + b; end"))
      end

      it "should be able to rewrite User.where(username: username).first" do
        ast = parse("User.where(username: username).first")

        # name.where(PARAMS).first -> name.find_by(PARAMS)
        # send(send(name, where, PARAMS), first) -> send(name, find_by, PARAMS)

        pattern = Node.new(
          name: :send,
          children: [
            Node.new(
              name: :send,
              children: [
                Variable.new(name: :name),
                Node.new(name: :where),
                Variable.new(name: :params)
              ]
            ),
            Node.new(
              name: :first
            )
          ]
        )

        replacement = Node.new(
          name: :send,
          children: [
            Variable.new(name: :name),
            Node.new(name: :find_by),
            Variable.new(name: :params)
          ]
        )

        rule = Rule.new(pattern: pattern, replacement: replacement)
        rewritten = rule.apply(ast)

        expect(rewritten).to eq(parse("User.find_by(username: username)"))
      end

      it "should allow replacements to be derived from pattern" do
        ast = parse("Person.pet")

        # name.METHOD -> name.PLURAL where PLURAL derives METHOD.name + "s"

        pattern = Node.new(
          name: :send,
          children: [
            Variable.new(name: :name),
            Variable.new(name: :method)
          ]
        )

        replacement = Node.new(
          name: :send,
          children: [
            Variable.new(name: :name),
            Derived.new(## is this not another rule?!
              base: [:method],
              derivation: lambda do |method|
                Node.new(name: (method.name.to_s + "s").to_sym)
              end
            )
          ]
        )

        rule = Rule.new(pattern: pattern, replacement: replacement)
        rewritten = rule.apply(ast)

        expect(rewritten).to eq(parse("Person.pets"))
      end

      it "should be able to rewrite Asset.find_by_asset_id_and_object_path(id, path)" do
        ast = parse("Asset.find_by_asset_id_and_object_path(id, path)")

        # send(name, DYNAMIC_FINDER, PARAMS...)
        #  where DYNAMIC_FINDER satisfies node.name.to_s.start_with?("find_by")
        # ->
        # send(name, find_by, HASH)
        #  where HASH
        #    substitutes [DYNAMIC_FINDER, PARAMS]
        #    by hash(
        #      pair(sym(KEYS[0]), PARAM[0]),
        #      ...,
        #      pair(sym(KEYS[N]), PARAM[N])
        #    ) where KEYS = DYNAMIC_FINDER.name["find_by_".length..-1].split("_and_")

        pattern = Node.new(
          name: :send,
          children: [
            Variable.new(name: :name),
            Variable.new(
              name: :dynamic_finder,
              condition: ->(node) { node.name.to_s.start_with?("find_by") }
            ),
            GreedyVariable.new(name: :params)
          ]
        )

        replacement = Node.new(
          name: :send,
          children: [
            Variable.new(name: :name),
            Node.new(name: :find_by),
            Derived.new(## is this not a substitution
              base: [:dynamic_finder, :params],
              derivation: lambda do |dynamic_finder, params|
                keys = dynamic_finder.name.to_s["find_by_".length..-1].split("_and_")

                pairs = keys.zip(params).map do |key, param|
                  Node.new(
                    name: :pair,
                    children: [
                      Node.new(
                        name: :sym,
                        children: [
                          Node.new(name: key.to_sym)
                        ]
                      ),
                      param
                    ]
                  )
                end
                Node.new(name: :hash, children: pairs)

              end
            )
          ]
        )

        rule = Rule.new(pattern: pattern, replacement: replacement)
        rewritten = rule.apply(ast)

        expect(rewritten).to eq(parse("Asset.find_by(asset_id: id, object_path: path)"))
      end
    end

    def parse(source)
      import(Parser::CurrentRuby.parse(source))
    end

    def import(ast)
      if ast.respond_to? :type
        Node.new(name: ast.type, children: ast.children.map { |c| import(c) })
      else
        Node.new(name: ast)
      end
    end
  end
end
