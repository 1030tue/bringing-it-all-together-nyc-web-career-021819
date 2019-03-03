class Dog

attr_accessor :id, :name, :breed

    def initialize(attributes)
      # id = nil, name:, breed:
      attributes.each{|key,val| self.send("#{key}=" , val)}
      self.id ||= nil
    end

    def self.create_table
      sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIME KEY
        name TEXT
        breed TEXT
      )
      SQL
      DB[:conn].execute(sql)
    end


    def self.drop_table
      sql = <<-SQL
      DROP TABLE IF EXISTS dogs
      SQL
      DB[:conn].execute(sql)
    end

    def save
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (? ,?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      return self
    end

    def self.create(attrbs)
      dog = self.new(attrbs)
      dog.save
    end


    def self.new_from_db(row)
      # create a new dog object given a row from the database
      attributes = {
        :id => row[0],
        :name => row[1],
        :breed => row[2]
      }
      self.new(attributes)
    end



    def self.find_by_id(id)
      sql = "SELECT * FROM dogs where id = ?"
      DB[:conn].execute(sql, id).map do |r|
        self.new_from_db(r)
      end.first
    end

    def self.find_or_create_by(name:, breed:)
      sql = "SELECT * FROM dogs WHERE name = ? AND breed =?"
      dog = DB[:conn].execute(sql, name, breed)
        if !dog.empty?
          newdog = self.new_from_db(dog[0])
        else
          newdog = self.create(name: name, breed: breed)
        end
        newdog
      end

      def self.find_by_name(name)
          sql = "SELECT * FROM dogs WHERE name = ?"

          DB[:conn].execute(sql, name).map do |r|
            self.new_from_db(r)
          end.first
        end

      def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
      end

end
