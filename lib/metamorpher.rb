require "metamorpher/version"
require "metamorpher/builders/default"
require "metamorpher/matcher"
require "metamorpher/rewriter"
require "metamorpher/refactorer"

module Metamorpher
  def self.builder
    @builder ||= Builders::Default::Builder.new
  end

  def self.configure(builder: :default)
    configure_builder(builder.to_s)
  end

  private

  def self.configure_builder(builder)
    require "metamorpher/builders/#{builder}/builder"
    @builder = Builders.const_get(builder.to_s.capitalize).const_get("Builder").new
  end
end
