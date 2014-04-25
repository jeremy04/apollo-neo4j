#!/usr/bin/env ruby
require "./config"
require "pp"
require "securerandom"
uuid = SecureRandom.hex(12)


node = Neo4j::Node.create({id: uuid}, uuid.to_sym)

start_node = Neo4j::Label.find_all_nodes(:start_node).first
first_question =  start_node.node(dir: :outgoing, type: :first_question)


pp node
pp first_question
Neo4j::Relationship.create(:current, node, first_question)

puts "Created node with #{uuid} label"
