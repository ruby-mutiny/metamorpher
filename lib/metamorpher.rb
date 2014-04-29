require "metamorpher/version"
require "metamorpher/builder"
require "metamorpher/matcher"
require "metamorpher/rewriter"
require "metamorpher/refactorer"

module Metamorpher
  def self.builder
    @builder ||= Metamorpher::Builder.new
  end
end
