# -*- encoding : utf-8 -*-
module AbAdmin
  module Concerns
    module AdminAddition
      extend ActiveSupport::Concern

      included do
        scope :admin, scoped
        scope :base, scoped
        scope :ids, lambda { |ids| where("#{quoted_table_name}.id IN (?)", AbAdmin.val_to_array(ids).push(0)) }

        class_attribute :batch_actions, :instance_writer => false
        self.batch_actions = [:destroy]
      end

      def next_prev_by_url(scope, url, prev=false)
        predicates = {'>' => '<', '<' => '>', 'desc' => 'asc', 'asc' => 'desc'}
        query = Rack::Utils.parse_nested_query(URI.parse(url).query).symbolize_keys
        query[:q] ||= {}
        order_str = query[:q]['s'] || 'id desc'
        order_col, order_mode = order_str.split
        quoted_order_col = self.class.quote_column(order_col)
        if prev
          query[:q]['s'] = ["#{order_col} #{predicates[order_mode]}", 'id desc']
          predicate = order_mode == 'desc' ? '>' : '<'
          id_predicate = '<'
        else
          query[:q]['s'] = ["#{order_col} #{order_mode}", 'id']
          predicate = order_mode == 'desc' ? '<' : '>'
          id_predicate = '>'
        end
        sql = "(#{quoted_order_col} #{predicate} :val OR (#{quoted_order_col} = :val AND #{self.class.quote_column('id')} #{id_predicate} #{self.id}))"
        scope.where(sql, :val => self.send(order_col)).ransack(query[:q]).result(:distinct => true).first
      end

    end
  end
end