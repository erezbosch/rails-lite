require_relative '../db_logic/sql_object'

class Cat < SQLObject
  belongs_to :owner, foreign_key: :owner_id, class_name: "Human"

  finalize!
end
