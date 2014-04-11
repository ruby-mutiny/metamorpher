require "metamorpher/rule"
require "metamorpher/literal"
require "metamorpher/variable"
require "metamorpher/derived"

require "parser/current"

module Metamorpher
  describe Literal do
    describe "simple" do
      it "Literals should match asts" do
        a = Literal.new(name: :send, children: [Literal.new(name: nil), Literal.new(name: :a)])
        b = Literal.new(name: :send, children: [Literal.new(name: nil), Literal.new(name: :b)])
        op = Literal.new(name: :^)

        pattern = Literal.new(name: :send, children: [a, op, b])

        ast = parse("a ^ b")
        result = pattern.match(ast)

        expect(result.matches?).to be_true
      end

      it "Literals should return a negative result when there is no match" do
        a = Literal.new(name: :send, children: [Literal.new(name: nil), Literal.new(name: :a)])
        b = Literal.new(name: :send, children: [Literal.new(name: nil), Literal.new(name: :b)])
        op = Literal.new(name: :^)

        pattern = Literal.new(name: :send, children: [a, op, b])

        ast = parse("a + b")
        result = pattern.match(ast)

        expect(result.matches?).to be_false
      end

      it "variables should capture the literals that they match" do
        x = Variable.new(name: :x)
        y = Variable.new(name: :y)
        op = Literal.new(name: :^)

        pattern = Literal.new(name: :send, children: [x, op, y])

        ast = parse("a ^ b")
        result = pattern.match(ast)

        expect(result.matches?).to be_true
        expect(result.match_for(x)).to eq(ast.children.first)
        expect(result.match_for(y)).to eq(ast.children.last)
      end

      it "should capture all remaining children" do
        name = Variable.new(name: :name)
        method = Literal.new(name: :find_by_name_and_birthday)
        params = Variable.new(name: :params, greedy?: true)

        pattern = Literal.new(name: :send, children: [name, method, params])

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
        pattern = Literal.new(name: :send, children: [x, Literal.new(name: :^), y])
        replacement = Literal.new(name: :send, children: [x, Literal.new(name: :+), y])
        rule = Rule.new(pattern: pattern, replacement: replacement)

        ast = parse("a ^ b")
        rewritten = rule.apply(ast)

        expect(rewritten).to eq(parse("a + b"))
      end

      it "should rewrite a nested term" do
        x = Variable.new(name: :x)
        y = Variable.new(name: :y)
        pattern = Literal.new(name: :send, children: [x, Literal.new(name: :^), y])
        replacement = Literal.new(name: :send, children: [x, Literal.new(name: :+), y])
        rule = Rule.new(pattern: pattern, replacement: replacement)

        ast = parse("def foo; a ^ b; end")
        rewritten = rule.apply(ast)

        expect(rewritten).to eq(parse("def foo; a + b; end"))
      end

      it "should be able to rewrite User.where(username: username).first" do
        ast = parse("User.where(username: username).first")

        # name.where(PARAMS).first -> name.find_by(PARAMS)
        # send(send(name, where, PARAMS), first) -> send(name, find_by, PARAMS)

        pattern = Literal.new(
          name: :send,
          children: [
            Literal.new(
              name: :send,
              children: [
                Variable.new(name: :name),
                Literal.new(name: :where),
                Variable.new(name: :params)
              ]
            ),
            Literal.new(
              name: :first
            )
          ]
        )

        replacement = Literal.new(
          name: :send,
          children: [
            Variable.new(name: :name),
            Literal.new(name: :find_by),
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

        pattern = Literal.new(
          name: :send,
          children: [
            Variable.new(name: :name),
            Variable.new(name: :method)
          ]
        )

        replacement = Literal.new(
          name: :send,
          children: [
            Variable.new(name: :name),
            Derived.new(## is this not another rule?!
              base: [:method],
              derivation: lambda do |method|
                Literal.new(name: (method.name.to_s + "s").to_sym)
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
        #  where DYNAMIC_FINDER satisfies Literal.name.to_s.start_with?("find_by")
        # ->
        # send(name, find_by, HASH)
        #  where HASH
        #    substitutes [DYNAMIC_FINDER, PARAMS]
        #    by hash(
        #      pair(sym(KEYS[0]), PARAM[0]),
        #      ...,
        #      pair(sym(KEYS[N]), PARAM[N])
        #    ) where KEYS = DYNAMIC_FINDER.name["find_by_".length..-1].split("_and_")

        pattern = Literal.new(
          name: :send,
          children: [
            Variable.new(name: :name),
            Variable.new(
              name: :dynamic_finder,
              condition: ->(dynamic_finder) { dynamic_finder.name.to_s.start_with?("find_by") }
            ),
            Variable.new(name: :params, greedy?: true)
          ]
        )

        replacement = Literal.new(
          name: :send,
          children: [
            Variable.new(name: :name),
            Literal.new(name: :find_by),
            Derived.new(## is this not a substitution
              base: [:dynamic_finder, :params],
              derivation: lambda do |dynamic_finder, params|
                keys = dynamic_finder.name.to_s["find_by_".length..-1].split("_and_")

                pairs = keys.zip(params).map do |key, param|
                  Literal.new(
                    name: :pair,
                    children: [
                      Literal.new(
                        name: :sym,
                        children: [
                          Literal.new(name: key.to_sym)
                        ]
                      ),
                      param
                    ]
                  )
                end
                Literal.new(name: :hash, children: pairs)

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
        Literal.new(name: ast.type, children: ast.children.map { |c| import(c) })
      else
        Literal.new(name: ast)
      end
    end
  end
end
