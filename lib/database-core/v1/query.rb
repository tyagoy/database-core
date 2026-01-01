module DatabaseCore::V1

  class Query

    def self.build table, query

      output = []

      build_select output, query

      output << "FROM `#{table}`"

      build_where output, query
      build_order output, query
      build_limit output, query
      build_offset output, query

      output.join " "
    end

    def self.build_select output, query

      columns = []

      build_keys columns, query

      unless query["columns"].nil?
        columns.concat query["columns"]
      end

      if columns.empty?
        output << "SELECT *"
      end

      unless columns.empty?
        columns.map!{ |column| "`#{column}`" }
        output << "SELECT #{columns.join ","}"
      end
    end

    def self.build_where output, query

      where = []

      unless query["equal"].nil?
        query["equal"].each do |key, value|
          where << "`#{key}`=#{value}"
        end
      end

      unless query["in_query"].nil?
        query["in_query"].each do |key, value|
          value.each do |table, query|
            query = build table, query
            where << "`#{key}` IN (#{query})"
          end
        end
      end

      unless query["in_value"].nil?
        query["in_value"].each do |key, value|
          unless value.empty?
            value = value.join ","
            where << "`#{key}` IN (#{value})"
          end
        end
      end

      unless query["like"].nil?
        query["like"].each do |key, value|
          where << "`#{key}` LIKE '#{value}'"
        end
      end

      unless where.empty?
        where = where.join " AND "
        output << "WHERE #{where}"
      end
    end

    def self.build_order output, query

      order = []

      unless query["order"].nil?
        query["order"].each do |key, value|
          order << "`#{key}` #{value}"
        end
      end

      unless order.empty?
        order = order.join ","
        output << "ORDER BY #{order}"
      end
    end

    def self.build_limit output, query

      unless query["limit"].nil?
        output << "LIMIT #{query["limit"]}"
      end
    end

    def self.build_offset output, query

      unless query["offset"].nil?
        output << "OFFSET #{query["offset"]}"
      end
    end

    def self.build_keys output, query

      unless query["has_one_key"].nil?
        unless output.include? "id"
          output << "id"
        end
      end

      unless query["has_many"].nil?
        unless output.include? "id"
          output << "id"
        end
      end

      unless query["has_many_key"].nil?
        unless output.include? query["has_many_key"]
          output << query["has_many_key"]
        end
      end

      unless query["has_one"].nil?
        query["has_one"].each do |table, query|
          unless query["has_one_key"].nil?
            unless output.include? query["has_one_key"]
              output << query["has_one_key"]
            end
          end
        end
      end
    end

  end

end