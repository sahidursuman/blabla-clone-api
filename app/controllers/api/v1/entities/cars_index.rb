# frozen_string_literal: true
module API
  module V1
    module Entities
      class CarsIndex < Grape::Entity
        present_collection true
        expose :items, as: "items", using: Entities::CarIndex

        expose :meta

        private

        def meta
          options[:pagination]
        end
      end
    end
  end
end
