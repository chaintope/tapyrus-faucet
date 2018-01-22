require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "残高に応じて配布する額を調整する" do
    t = Transaction.new

    ary = t.dist_value_ary(500)
    assert(average(ary) > 3.9)
    assert(average(ary) < 39)
    assert(ary.max == 39)

    ary = t.dist_value_ary(400)
    assert(average(ary) > 0.00114114)
    assert(average(ary) < 0.05)
    assert(ary.max == 0.05)

    ary = t.dist_value_ary(399.9999999)
    assert(average(ary) > 0.0002)
    assert(average(ary) < 0.0003)
  end

  def average(ary)
    ary.sum / ary.size
  end
end
