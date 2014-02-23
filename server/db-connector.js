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
  console.log( req.body );
  res.jsonp( ["hello"] );
}

exports.getHighScoresByLevel = function( req, res ) {
  var level = req.params.level
  db.collection( "commands", function( e, collection ) {
    collection.find( { "level": level } ).toArray( function( e, items ) {
      items.sort( function( a, b ) {
        if ( a.commands.length < b.commands.length ) return -1;
        if ( a.commands.length > b.commands.length ) return 1;
        return 0;
      } );
      // only get top 10
      res.jsonp( items.slice( 0, 10 ) );
    } )
  } );
}

var populateDBWithTestData = function() {
  var commands = [
   { "level": "intro", "player": "desktop", "commands": [ "mr", "md" ] },
   { "level": "intro", "player": "desktop", "commands": [ "mr", "mr", "md" ] },
   { "level": "square", "player": "desktop", "commands": [ "1", "0", "mr", "1", "0", "md" ] },
   { "level": "short", "player": "desktop", "commands": [ "8", "mr" ] },
   { "level": "long", "player": "desktop", "commands": [ "1", "0", "0", "mr" ] },
  ];

  db.collection( "commands", function( e, collection ) {
    collection.insert( commands, { safe : true }, function( e, r ) {} );
  } );
}
