var MongoClient = require('mongodb').MongoClient,
    Server = require('mongodb').Server,
    db;

var mongoClient = new MongoClient( new Server( 'localhost', 27017 ) );
mongoClient.open( function( e, mongoClient ) {
  db = mongoClient.db( "automatondb14" );
  db.collection( "commands", { strict : true }, function( e, collection ) {
    if ( e ) {
      console.log( "commands collection does not exist. Injecting test data..." );
      populateDBWithTestData();
    }
  } );
} );

exports.submitScore = function( req, res ) {

}

exports.getHighScores = function( req, res ) {

}

var populateDBWithTestData = function() {
  var commands = [
   { "level": "art/levels/intro", "player": "desktop", "commands": [ "mr", "md" ] },
   { "level": "art/levels/intro", "player": "desktop", "commands": [ "mr", "mr", "md" ] },
   { "level": "art/levels/square", "player": "desktop", "commands": [ "1", "0", "mr", "1", "0", "md" ] },
   { "level": "art/levels/short", "player": "desktop", "commands": [ "8", "mr" ] },
   { "level": "art/levels/long", "player": "desktop", "commands": [ "1", "0", "0", "mr" ] },
  ];

  db.collection( "commands", function( e, collection ) {
    collection.insert( commands, { safe : true }, function( e, r ) {} );
  } );
}
