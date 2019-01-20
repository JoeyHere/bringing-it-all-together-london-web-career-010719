class Dog

  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
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
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten.first
    self
  end

  def self.create(name:, breed:)
    self.new(name: name, breed: breed).save
  end

  def self.find_by_id(id)
    name, breed = DB[:conn].execute("SELECT name, breed FROM dogs WHERE id = ?", id).first
    self.new(id: id, name: name, breed: breed)
  end

  def self.find_or_create_by(name:, breed:)
    id = DB[:conn].execute("SELECT id FROM dogs WHERE name = ? AND breed = ?", name, breed).flatten.first
    id ? self.find_by_id(id) : self.create(name: name, breed: breed)
  end

  def self.new_from_db(row)
    id, name, breed = row
    self.new(id: id, name: name, breed: breed)
  end

  def self.find_by_name(name)
    id = DB[:conn].execute("SELECT id FROM dogs WHERE name = ?", name).flatten.first
    self.find_by_id(id)
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", name, breed, id)
  end

end
