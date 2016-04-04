# README

#### Requirements:

- Java JDK 1.6 or greater

- Neo4j server version 2.1.8

I personally installed it as a stand alone binary, go ahead and use brew if you'd like

#### Dev setup



Install and start neo4j server

```
brew tap artcom/neo4jversions
brew install neo4j218
neo4j-218 start
```
``` 
cd ~/projects
git clone git@github.com:jeremy04/apollo-neo4j.git
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


#### View 'graph'

http://localhost:7474/


#### Generate a survey id

To start a survey you need to 'generate' a uuid (simulating an email)

```
bundle exec ruby ./lib/create_session.rb
```

Output should look like:

```
CypherNode 26829 (70324442930820)
CypherNode 26813 (70324442942520)
Created node with '109015c85741f8716b2bca2e' label
```

Copy '109015c85741f8716b2bca2e' to your clipboard


#### Start sinatra

```
bundle exec ruby app.rb
```

#### Try out survey at

http://localhost:4567/survey/109015c85741f8716b2bca2e
