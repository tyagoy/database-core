# frozen_string_literal: true

require_relative "database/version"

Dir[File.join(__dir__, "database/**/*.rb")].sort.each do |file|
  require file
end
