class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.add_condition(conditions, condition)
    if conditions.present?
      return "#{conditions} AND #{condition}"
    else
      return condition
    end
  end

  def self.sanitized_order(order_by, direction = 'ASC')
    unless order_by.present?
      return order(nil)
    end
    
    # if order_by.include?('.')
    #   klass, column = order_by.split('.')
    #   unless ([model_name.plural.to_sym] + joins_values).include?(klass.pluralize.to_sym)
    #     raise "#{klass} unavailable in query"
    #   end
    #   klass = klass.singularize.classify.constantize
    # else
    #   klass = self.klass
    #   column = order_by
    # end
    
    raise "Column #{order_by} not found in table" unless column_names.include?(order_by)
    raise 'Invalid direction value' unless %w[ASC DESC].include?(direction)

    order(sanitize_sql_array(['%s %s', order_by, direction]))
  end
end
