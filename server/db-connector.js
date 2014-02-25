// Hack to find indexOf by using _id property
Array.prototype.mongoIndexOf = function( searchElement, fromIndex ) {
  var i,
      pivot = ( fromIndex ) ? fromIndex : 0,
      length;

  if ( !this ) {
    throw new TypeError();
  }

  length = this.length;

  if ( length === 0 || pivot >= length ) {
    return -1;
  }

  if ( pivot < 0 ) {
    pivot = length - Math.abs( pivot );
  }

  for ( i = pivot; i < length; i++ ) {
    if ( this[i]._id && searchElement._id && this[i]._id.equals( searchElement._id ) ) { // HACK here
      return i;
    } else if ( this[i] === searchElement ) {
      return i;
    }
  }
  return -1;
}

var MongoClient = require('mongodb').MongoClient,
    Server = require('mongodb').Server,
    db;

var mongoClient = new MongoClient( new Server( 'localhost', 27017 ) );
mongoClient.open( function( e, mongoClient ) {
  db = mongoClient.db( "automatondb14" );
  db.collection( "commands", { strict : true }, function( e, collection ) {} );
} );

sortByIncreasingCommandLength = function( a, b ) {
  if ( a.commands.length < b.commands.length ) return -1;
  if ( a.commands.length > b.commands.length ) return 1;
  return 0;
}

exports.submitScore = function( req, res ) {
  req.body.commands = JSON.parse( req.body.commands ); // parse the array
  db.collection( "commands", function( e, collection ) {
    collection.insert( req.body, { safe : true }, function( e, insertedCommands ) {
      collection.find( { "level": insertedCommands[0].level } ).toArray( function( e, items ) {
        items.sort( sortByIncreasingCommandLength );
        var rank = items.mongoIndexOf( insertedCommands[0] ) + 1;
        if ( rank > -1 ) {
          var percentile = 100 - ( 100 * ( rank - 0.5 ) ) / items.length;
          res.jsonp( percentile );
        } else {
           console.log( "error calculating rank: == -1" );
        }
      } );
    } );
  } );
}

exports.getHighScoresByLevel = function( req, res ) {
  var level = req.params.level
  var cutoff = 10;
  if ( req.params.cutoff ) {
    cutoff = parseInt( req.params.cutoff )
  }
  db.collection( "commands", function( e, collection ) {
    collection.find( { "level": level } ).toArray( function( e, items ) {
      items.sort( sortByIncreasingCommandLength );
      res.jsonp( items.slice( 0, cutoff ) );
    } )
  } );
}
