module Database::V3

  class UpdateRunner

    def self.update input

      input.each do |model, payload|

        Array.wrap(payload).each do |item|

          sql = UpdateModel.build(model, item)

          ActiveRecord::Base.connection.execute(sql)
        end
      end
    end

  end

end