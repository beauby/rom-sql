module ROM
  module SQL
    module Plugin
      module Pagination
        class Pager
          include Options
          include Equalizer.new(:current_page, :per_page)

          option :current_page, reader: true, default: 1
          option :per_page, reader: true

          attr_reader :dataset
          attr_reader :current_page

          def initialize(dataset, options = {})
            @dataset = dataset
            super
          end

          def next_page
            num = current_page + 1
            num if total_pages >= num
          end

          def prev_page
            num = current_page - 1
            num if num > 0
          end

          def total
            dataset.unlimited.count
          end

          def total_pages
            (total / per_page) + 1
          end

          def at(num)
            self.class.new(
              dataset.offset((num-1)*per_page).limit(per_page),
              options.merge(current_page: num)
            )
          end
        end

        def self.included(klass)
          super

          klass.class_eval do
            defines :per_page

            option :pager, reader: true, default: proc { |relation|
              Pager.new(relation.dataset, per_page: relation.class.per_page)
            }
          end
        end

        # Paginate a relation
        #
        # @example
        #   rom.relation(:users).class.per_page(10)
        #   rom.relation(:users).page(1)
        #   rom.relation(:users).pager # => info about pagination
        #
        # @return [Relation]
        #
        # @api public
        def page(num)
          next_pager = pager.at(num)
          __new__(next_pager.dataset, pager: next_pager)
        end
      end
    end
  end
end
