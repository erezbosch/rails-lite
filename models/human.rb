require_relative '../db_logic/sql_object'

class Human < SQLObject
  self.table_name = 'humans'

  has_many :cats, foreign_key: :owner_id

  finalize!
end
