module Stupidedi
  module Envelope

    class TransactionSetDef
      # @return [String]
      attr_reader :id

      # @return [String]
      attr_reader :functional_group

      # @return [Array<TableDef>]
      attr_reader :table_defs

      def initialize(functional_group, id, table_defs)
        @functional_group, @id, @table_defs =
          functional_group, id, table_defs

        # @todo: This assigns an implied parsing order, but depending on the
        # order in which tables can occur, either the user should assign these
        # when calling TableDef.build or the parser should implicitly order the
        # tables on its own. This is temporary
        position    = 0
        @table_defs = table_defs.map{|x| x.copy(:parent => self, :position => (position += 1)) }
      end

      def copy(changes = {})
        self.class.new \
          changes.fetch(:functional_group, @functional_group),
          changes.fetch(:id, @id),
          changes.fetch(:table_defs, @table_defs)
      end

      def value(header_segment_vals, parent = nil)
        TransactionSetVal.new(self, @table_defs.head.value(header_segment_vals, [], []).cons, parent)
      end

      def empty(parent = nil)
        TransactionSetVal.new(self, [], parent)
      end

      # @return [SegmentUse]
      def first_segment_use
        @table_defs.head.header_segment_uses.head
      end

      # @return [SegmentUse]
      def last_segment_use
        @table_defs.last.trailer_segment_uses.last
      end

      # @private
      def pretty_print(q)
        q.text("TransactionSetDef[#{@functional_group}#{@id}]")
        q.group(2, "(", ")") do
          q.breakable ""
          @table_defs.each do |e|
            unless q.current_group.first?
              q.text ","
              q.breakable
            end
            q.pp e
          end
        end
      end
    end

    class << TransactionSetDef
      def build(functional_group, id, *table_defs)
        new(functional_group, id, table_defs)
      end
    end

  end
end