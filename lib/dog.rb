class Dog
    attr_accessor :id, :name, :breed

    def initialize(id:nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].last_insert_row_id()
        self
    end

    def self.create(dog_hash)
        dog = self.new(dog_hash)
        dog.save
    end

    def self.new_from_db(db_row)
        id = db_row[0]
        name = db_row[1]
        breed = db_row[2]
        self.new(id: id, name: name, breed: breed)
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE dogs.id = ?
        LIMIT 1
        SQL
        result = DB[:conn].execute(sql, id)[0]
        self.new_from_db(result)
    end

    def self.find_or_create_by(dog_hash)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE dogs.name = ? AND dogs.breed = ?
        SQL
        result = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed])
        if result.empty?
            dog = self.create(dog_hash)
        else
            dog = self.find_by_id(result[0][0])
        end
        dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE dogs.name = ?
        LIMIT 1
        SQL
        result = DB[:conn].execute(sql, name)[0]
        self.new_from_db(result)
    end

    def update
        sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end