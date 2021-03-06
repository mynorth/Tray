module Tray
  module Models
    class LineItem
      include Virtus.model

      attribute :id, Integer, default: -> _, attribute {UUID.generate}
      attribute :product_model, Symbol
      attribute :product_id, Integer
      attribute :quantity, Integer, default: 0
      attribute :options, Hash, default: {}
      attribute :created_at, DateTime, default: -> _, attribute {Time.now}
      attribute :applied_discount_amounts, Array[Hash], default: []

      def entity
        @entity ||= Cart::PRODUCT_KEYS.invert[product_model].find(product_id)
      end

      def options
        (super || {}).with_indifferent_access
      end

      def delivery_fee
        return entity.event.mailing_fee_in_cents if options[:delivery_method].to_s == "mail" && product_model == :ticket
        return entity.mailing_fee_in_cents if options[:delivery_method].to_s == "mail" && product_model == :ticket_package
        return 0
      end

      def valid?
        return true unless product_model == :ticket_package
        return true if options[:finished]
      end

      def discount_total
        applied_discount_amounts.map{|amount| amount.fetch(:amount, 0)}.reduce(0,&:+)
      end

      def discount_total_in_dollars
        discount_total / 100.0
      end
    end
  end
end