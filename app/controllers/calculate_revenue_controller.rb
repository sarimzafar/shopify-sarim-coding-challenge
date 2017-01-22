require 'rubygems'
require 'rest_client'

class CalculateRevenueController < ApplicationController

  def index
    page = 1
    @current_total_cost = 0
    @invoice_cost = []
    orders = make_api_call(page)

    while validate_order_size(orders) do
      @current_total_cost += calculate_total_cost_per_page orders
      page += 1
      orders = make_api_call(page)
    end
  end

  private

    def calculate_total_cost_per_page(orders)
      page_cost = 0
      orders["orders"].each do |order|
        order_detail = {:email => order["email"], :items_price => order["total_line_items_price"].to_f }
        @invoice_cost << order_detail
        page_cost = page_cost + order["total_line_items_price"].to_f # Because the revenue does not include tax and shipping
      end
      return page_cost
    end

    def construct_orders_page_uri(page = 1)
      shopify_uri =  "https://shopicruit.myshopify.com/admin"
      fetch_orders = "orders.json"
      access_token = "c32313df0d0ef512ca64d5b336a0d7c6"

      base_uri = "#{shopify_uri}/#{fetch_orders}?page=#{page}&access_token=#{access_token}"
    end

    def make_api_call(page = 1)
      shopify_uri = construct_orders_page_uri(page)
      page_orders = RestClient::Resource.new(shopify_uri).get

      page_orders = JSON.parse(page_orders)
    end

    def get_order_size(orders)
      orders["orders"].size
    end

    def validate_order_size(orders)
      if get_order_size(orders) > 0
        true
      else
        false
      end
    end
end
