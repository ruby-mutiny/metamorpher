require "metamorpher/version"
require "metamorpher/builders/ruby"

require "metamorpher/support/map_at"

require "metamorpher/matcher"
require "metamorpher/rewriter"
require "metamorpher/refactorer"

module Metamorpher
  def self.builder
    @builder ||= Builders::Ruby::Builder.new
  end

  def self.configure(builder: :ast)
    configure_builder(builder)
  end

  private

  def self.configure_builder(builder)
    require "metamorpher/builders/#{builder}/builder"
    @builder = builder_class_for(builder).new
  end

  def self.builder_class_for(name)
    namespace = name == :ast ? "AST" : name.to_s.capitalize
    Builders.const_get(namespace).const_get("Builder")
  end
end
