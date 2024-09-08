#!/bin/sh

# open connection
ssh -L 10022:lkdb:5432 students

# test connection
# psql "sslmode=require host=localhost port=5432 dbname=bd user=gc429174"
