#!/bin/bash

nc localhost -q 0 `cat masterport` << END
`sleep 2;echo EOF`
END
