module DatabaseCore::V2

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

      where_rules = []

      unless query["where_and"].nil?
        where_rules << Wherer.build(query["where_and"]).join(" AND ")
      end

      unless query["where_or"].nil?
        where_rules << Wherer.build(query["where_and"]).join(" OR ")
      end

      unless where_rules.empty?
        output << "WHERE #{where_rules.join(" AND ")}"
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