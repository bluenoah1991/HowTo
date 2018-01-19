# Build CoffeeScript  

### Browserify  

access `http://browserify.org/`  

### Install  

execute below commands  

	coffeeify
	npm install -g browserify
	npm install -g less
	npm install -g coffee-script

	curl --silent --location https://deb.nodesource.com/setup_0.12 | sudo bash -
	apt-get install --yes nodejs

	npm install coffeeify

### Build  

	browserify -t coffeeify xyz.coffee -o xyz.js
