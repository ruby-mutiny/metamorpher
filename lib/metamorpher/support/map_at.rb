module Enumerable
  # Returns a new array with the element at _index_ replaced by the result of
  # running _block_ on that element.
  def map_at(index, &block)
    fail IndexError if index < 0 || index >= size
    each_with_index.map { |e, i| i == index ? block.call(e) : e }
  end
end
