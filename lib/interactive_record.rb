require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
#get table name
  def self.table_name
    self.to_s.downcase.pluralize
  end
#get column_names
  def self.column_names
     DB[:conn].results_as_hash = true

     sql = "pragma table_info('#{table_name}')"

     table_info = DB[:conn].execute(sql)
     column_names = []
     table_info.each do |row|
       column_names << row["name"]
     end
     column_names.compact
   end

#create instance, you need to create the accesor first in the class file.rb
   def initialize(options={})
     options.each do |property, value|
       self.send("#{property}=", value)
     end
   end

#get the table name for insert data
    def table_name_for_insert
     self.class.table_name
    end

#get the column names for insert data
    def col_names_for_insert
      self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    end

#get the values for the column names for insert
      def values_for_insert
          values = []
          self.class.column_names.each do |col_name|
            values << "'#{send(col_name)}'" unless send(col_name).nil?
          end
          values.join(", ")
        end

#With the methods below now you can save data.
      def save
        sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
      end

#find_by_name using the abstraction
    def self.find_by_name(name)
        sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
        DB[:conn].execute(sql)
      end

    def self.find_by(search={})

       k = v = " "
         k = search.keys[0].to_s
         v = search[search.keys[0]]
      sql = "SELECT * FROM #{self.table_name} WHERE #{k} = '#{v}'"
      DB[:conn].execute(sql)
    end

end
