module Database::V2

  class Wherer

    def self.build query

      where_rules = []

      unless query["bigger"].nil?
        query["bigger"].each do |key, value|
          where_rules << "`#{key}` = #{value}"
        end
      end

      unless query["smaller"].nil?
        query["smaller"].each do |key, value|
          where_rules << "`#{key}` = #{value}"
        end
      end

      unless query["different"].nil?
        query["different"].each do |key, value|
          where_rules << "`#{key}` = #{value}"
        end
      end

      unless query["equal"].nil?
        query["equal"].each do |key, value|
          where_rules << "`#{key}` = #{value}"
        end
      end

      unless query["in_query"].nil?
        query["in_query"].each do |key, value|
          value.each do |table, query|
            query = Query.build table, query
            where_rules << "`#{key}` IN (#{query})"
          end
        end
      end

      unless query["in_value"].nil?
        query["in_value"].each do |key, value|
          unless value.empty?
            value = value.join ","
            where_rules << "`#{key}` IN (#{value})"
          end
        end
      end

      unless query["like"].nil?
        query["like"].each do |key, value|
          where_rules << "`#{key}` LIKE '#{value}'"
        end
      end

      where_rules
    end

  end

end