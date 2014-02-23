express = require( 'express' );
connector = require( './db-connector' );

var robo = express();

robo.post( '/submitscore', connector.submitScore );
robo.get( '/gethighscores/', connector.getHighScores );

robo.listen( 6000 );
