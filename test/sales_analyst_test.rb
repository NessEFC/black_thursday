require_relative'test_helper'
require'./lib/sales_engine'
require'./lib/sales_analyst'

class SalesEngineTest < Minitest::Test
	attr_reader :se, :sa

	def setup
		@se = SalesEngine.from_csv({
			:items         => "./test/fixtures/items_reduced.csv",
			:merchants     => "./test/fixtures/merchant_reduced.csv",
			:invoices      => "./test/fixtures/invoices_reduced.csv",
			:invoice_items => "./test/fixtures/inv_items_reduced.csv",
			:transactions  => "./test/fixtures/transactions_reduced.csv",
			:customers     => "./test/fixtures/customers_reduced.csv"
		})
		@sa = SalesAnalyst.new(se)
	end

  def test_hash_of_pathnames_can_be_passed_into_sales_engine
		ir = se.items
		mr = se.merchants
    assert_instance_of ItemRepository, ir
    assert_instance_of MerchantRepository, mr
  end

	def test_merchants_can_find_by_name_from_sales_engine
    mr = se.merchants
    merchant_1 = mr.find_by_name("Shopin1901")

    assert_instance_of Merchant, merchant_1
		assert_equal 12334105, merchant_1.id
		assert_equal "Shopin1901", merchant_1.name
	end

	def test_merchant_and_items_communicate
		merchant = se.merchants.find_by_id("12334185")
		assert_equal 2, merchant.items.count
		item = se.items.find_by_id(263395617)
		assert_instance_of Merchant, item.merchant
		assert_equal 12334185, item.merchant.id
		assert_equal "Madewithgitterxx", item.merchant.name
	end

	def test_sales_analyst_exists
		assert_instance_of SalesAnalyst, sa
	end

	def test_average_items_per_merchant
		assert_equal 1.33, sa.average_items_per_merchant
	end

	def test_standard_deviation
		assert_equal 1.08, sa.average_items_per_merchant_standard_deviation
	end

	def test_average_invoices_per_merchant
		assert_equal 0.33, sa.average_invoices_per_merchant
	end

	def test_average_invoices_per_merchant_standard_deviation
		assert_equal 0.58, sa.average_invoices_per_merchant_standard_deviation
	end

	def test_top_merchants_by_invoice_count
		assert_equal [], sa.top_merchants_by_invoice_count
	end

	def test_bottom_merchants_by_invoice_count
		assert_equal [], sa.bottom_merchants_by_invoice_count
	end

	def test_invoice_status
		assert_equal 60.71, sa.invoice_status(:shipped)
		assert_equal 35.71, sa.invoice_status(:pending)
		assert_equal 3.57, sa.invoice_status(:returned)
	end

	def test_top_days_by_invoice_count
		assert_equal ["Friday"], sa.top_days_by_invoice_count
	end

  def test_average_item_price_per_merchant
    assert_equal 65.56, sa.item_price_standard_deviation
    assert_equal 51, sa.average_item_price.to_i
  end

  def test_average_items_per_merchant_standard_deviation
    assert_equal 1.08, sa.average_items_per_merchant_standard_deviation
  end

  def test_merchant_items
    assert_equal 1.33, sa.average_items_per_merchant
    assert_equal [2, 1, 0], sa.total_items_each_merchant
    assert_equal [], sa.merchants_with_high_item_count
    assert_equal 1.33, sa.average_items_per_merchant
    assert_equal 29, sa.average_item_price_for_merchant(12334105).to_i
    assert_equal 263396255, sa.golden_items[0].id
    assert_equal 12334389, sa.merchants_with_pending_invoices[0].id
    assert_equal 12334185, sa.merchants_ranked_by_revenue[0].id
    assert_equal "Shopin1901", sa.merchants_with_only_one_item[0].name
    assert_equal [0, 0, 0], sa.merchant_totals
  end

  def test_merchant_invoice
    assert_equal 0.58, sa.average_invoices_per_merchant_standard_deviation
    assert_equal [0, 0, 1], sa.total_invoices_of_each_merchant
    assert_equal "Sunday", sa.find_top_days_by_invoice_count(sa.average_items_per_merchant)[0]
    assert_equal 2.0, sa.average_invoices_per_day_standard_deviation
    assert_equal 4.0, sa.average_invoices_created_per_day
  end

  def test_number_or_status
    assert_equal 10, sa.number_of_invoices(:pending)
    assert_equal 17, sa.number_of_invoices(:shipped)
    assert_equal 1, sa.number_of_invoices(:returned)
  end

  def test_revenue
    assert_equal 0, sa.total_revenue_by_date("2013-01-30")
  end
  
end