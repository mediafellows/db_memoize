module ActiveRecord
  module Metal
    def self.included(base)
      base.extend ClassMethods
      # base.metal # initialize the metal adapter
    end

    module ClassMethods
      def metal
        @metal ||= Adapter.new(self)
      end
    end

    class Adapter
      class PkInfo
        attr_reader :column, :type

        def initialize(base_klass)
          @column = base_klass.primary_key
          @type   = @column && base_klass.columns_hash.fetch(@column).type
        end
      end

      def initialize(base_klass)
        @base_klass  = base_klass
        @query_cache = {}
      end

      private

      # setup primary key information. This is necessary to allow the create! method
      # to return the primary key of a newly created entry.
      def primary_key
        @primary_key ||= PkInfo.new(@base_klass)
      end

      def table_name
        @base_klass.table_name
      end

      def raw_connection
        @base_klass.connection.raw_connection # do not memoize me!
      end

      def column?(column_name)
        @base_klass.columns_hash.key?(column_name)
      end

      def insert_sql(field_names)
        @query_cache[field_names] ||= _insert_sql(field_names)
      end

      DATABASE_IDENTIFIER_REGEX = /\A\w+\z/

      def check_database_identifiers!(*strings)
        strings.each do |s|
          next if DATABASE_IDENTIFIER_REGEX =~ s.to_s
          raise ArgumentError, "Invalid database identifier: #{s.inspect}"
        end
      end

      def _insert_sql(field_names)
        check_database_identifiers! table_name, *field_names

        placeholders = 0.upto(field_names.count - 1).map { |idx| "$#{idx + 1}" }

        if column?('created_at')
          field_names << 'created_at'
          placeholders << 'current_timestamp'
        end

        if column?('updated_at')
          field_names << 'updated_at'
          placeholders << 'current_timestamp'
        end

        sql = "INSERT INTO #{table_name} (#{field_names.join(',')}) VALUES(#{placeholders.join(',')})"
        sql += " RETURNING #{primary_key.column}" if primary_key.column
        sql
      end

      public

      def create!(record)
        keys, values = record.to_a.transpose

        sql    = insert_sql(keys)
        result = raw_connection.exec_params(sql, values)

        # if we don't have an ID column then the sql does not return any value. The result
        # object would be this: #<PG::Result status=PGRES_COMMAND_OK ntuples=0 nfields=0 cmd_tuples=1>
        # we just return nil in that case; otherwise we return the first entry of the first result row
        # which would be the stringified id.
        first_row = result.each_row.first
        return nil unless first_row

        id = first_row.first
        primary_key.type == :integer ? Integer(id) : id
      end
    end
  end
end
