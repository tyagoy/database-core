module Database::V3

  class WhereModel

    OPERATORS = {

      "="     => "=",
      "!="    => "!=",
      "<>"    => "<>",
      ">"     => ">",
      "<"     => "<",
      ">="    => ">=",
      "<="    => "<=",
      "in"    => "IN",
      "like"  => "LIKE",
      "!in"   => "NOT IN",
      "!like" => "NOT LIKE",
    }

    def self.build output, query

      where = []

      where << query["and"].to_h.map{ |key, value| build_scopes(" AND ", key, value) }.compact_blank.join(" AND ")

      where << query["or"].to_h.map{ |key, value| build_scopes(" OR ", key, value) }.compact_blank.join(" OR ")

      where = where.compact_blank.join(" AND ")

      return unless where.present?

      output << "WHERE #{where}"
    end

    def self.build_scopes scope, column, rules

      if rules.is_a? FalseClass

        return build_rules(column, "=", rules)
      end

      if rules.is_a? TrueClass

        return build_rules(column, "=", rules)
      end

      if rules.is_a? Numeric

        return build_rules(column, "=", rules)
      end

      if rules.is_a? String

        return build_rules(column, "contains", rules)
      end

      output = build_scope(scope, column, rules)

      output.present? ? "(#{output})" : ""
    end

    def self.build_scope scope, column, rules

      case column
      when "and"
        return rules.map{ |key, value| build_scopes(" AND ", key, value) }.compact_blank.join(" AND ")
      when "or"
        return rules.map{ |key, value| build_scopes(" OR ", key, value) }.compact_blank.join(" OR ")
      else
        return rules.map{ |key, value| build_rules(column, key, value) }.compact_blank.join(scope)
      end
    end

    def self.build_rules column, operator, value

      case operator
      when "and"
        return build_scopes(" AND ", column, value)
      when "or"
        return build_scopes(" OR ", column, value)
      else
        return build_rule(column, operator, value)
      end
    end

    def self.build_rule column, operator, value

      return "" if value.is_a? NilClass

      column = Sanitize.target(column)

      if operator == "null"

        value = value ? " " : " NOT "

        return "`#{column}` IS#{value}NULL"
      end

      if operator == "last"
        return Sanitize.array(["`#{column}` LIKE ?", "%#{value}"])
      end

      if operator == "first"
        return Sanitize.array(["`#{column}` LIKE ?", "#{value}%"])
      end

      if operator == "contains"
        return Sanitize.array(["`#{column}` LIKE ?", "%#{value}%"])
      end

      operator = get_operator(operator)

      if value.is_a? Numeric
        return Sanitize.array(["`#{column}` #{operator} ?", value])
      end

      if value.is_a? String
        return Sanitize.array(["`#{column}` #{operator} ?", value])
      end

      if value.is_a? Array
        return Sanitize.array(["`#{column}` #{operator} (?)", value])
      end

      if value.is_a? Hash

        value = value.map{ |model, query| QueryModel.build(model, query) }

        value = value.map{ |value| "(#{value})" }.join(" UNION ")
      end

      "`#{column}` #{operator} #{value}"
    end

    def self.get_operator operator

      return OPERATORS[operator] if OPERATORS.key?(operator)

      raise KeyError, operator
    end

  end

end