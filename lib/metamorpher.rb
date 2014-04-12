require "metamorpher/version"
require "metamorpher/builder"
require "metamorpher/rewriter"

module Metamorpher
  def self.builder
    @builder ||= Metamorpher::Builder.new
  end
end
