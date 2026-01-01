module DatabaseCore::V3

  class InsertRunner

    def self.insert input

      input.each do |model, payload|

        Array.wrap(payload).each do |item|

          sql = InsertModel.build(model, item)

          ActiveRecord::Base.connection.execute(sql)
        end
      end
    end

  end

end