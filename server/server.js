express = require( 'express' );
connector = require( './db-connector' );

var robo = express();

robo.post( '/submitscore', connector.submitScore );
robo.get( '/gethighscores/:level', connector.getHighScoresByLevel );

robo.listen( 7000 );
