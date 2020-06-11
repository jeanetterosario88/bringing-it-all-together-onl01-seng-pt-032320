class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

   def self.create_table
       sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
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
      if self.id
        self.update
      else
        sql = <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      end
      self
    end

    def self.create(name:, breed:)
      dog = Dog.new(name: name, breed: breed)
      dog.save
      dog
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        found = DB[:conn].execute(sql, id)[0]
        newdog = Dog.new(id: found[0], name: found[1], breed: found[2])
        newdog
    end

    def self.find_or_create_by(name:, breed:)
      sql = <<-SQL
        SELECT *
        FROM dogs
         WHERE name = hash[:name]
         AND breed = hash[:breed]
         SQL
          dog = DB[:conn].execute(sql, name, breed)
          if !dog.empty?
            dogdata = dog[0]
            thedog = self.new_from_db(dogdata)
            #Dog.new(id: dog[0], name: dog[1], breed: dog[2])
          else
            thedog = self.create(name: name, breed: breed)
          end
          thedog
        end



# def self.find_or_create_by(hash)
    #    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    #    if !dog.empty?
    #      dog_data = dog[0]
    #      dog = new_from_db(dog_data)
    #    else
    #      dog = self.create(name: name, breed: breed)
    #    end
    #    dog
    #  end

  #   def self.find_or_create_by(hash)
  #     sql = <<-SQL
  #     SELECT *
  #     FROM dogs
  #     WHERE name = hash[:name]
  #     AND breed = hash[:breed]
  #     SQL
  #     result = DB[:conn].execute(sql, hash).flatten
  #     if !result.empty?
  #       thedog = Dog.new(id: dog[0], name: dog[1], breed: dog[2])
  #     else
  #       thedog = self.create(name, breed)
  #   end
  #   thedog
  # end

    def self.new_from_db(row)
      id = row[0]
      name = row[1]
      breed = row[2]
      dog = self.new(id: id, name: name, breed: breed)
      dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE name = ?
          LIMIT 1
        SQL
        DB[:conn].execute(sql,name).map do |row|
          self.new_from_db(row)
        end.first
      end

      def self.update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, name, breed, id)
      end


end
