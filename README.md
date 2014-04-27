# README

#### Requirements:

Jave JDK 1.6 or greater

Neo4j server

```
brew install neo4j && neo4j start
```

```
cd ~/projects/apollo-neo4j/
rbenv gemset create 1.9.3-p448 neo4j
gem install bundler
bundle install
```

#### Create "supply survey"

For simplicity, we want to create a supply survey in neo4j, this script will remove all existing nodes/relationships and 'migrate' the new survey

```
bundle exec ruby create_graph.rb
```

#### Generate a survey id

To start a survey you need to 'generate' a uuid (simulating an email)

```
bundle exec ruby ./lib/create_session.rb
```

Output should look like:
Created node with '109015c85741f8716b2bca2e' label

Take note of uuid


#### Start sinatra

```
bundle exec ruby app.rb
```

#### Try out survey at

http://localhost:4567/survey/109015c85741f8716b2bca2e