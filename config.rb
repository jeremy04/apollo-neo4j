require "neo4j-core" unless defined?(Neo4j)

NEO_DB = Neo4j::Session.open(:server_db, "http://localhost:7474")
