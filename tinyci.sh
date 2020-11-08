#!/usr/bin/env bash

# ./runner.sh is supposed to run on the server where your git repository lives

# the logic in here will run in an infinite loop:
# * (block and) wait for a job
# * run it
while :
do

# Announce that we're waiting
echo "Job runner waiting"

# We are using https://redis.io/commands/blpop to block until we have a new
# message on the "jobs" list. We use `tail` to get the last line because the
# output of BLPOP is of the form "list-that-got-an-element\nelement"
jobid=$(redis-cli blpop jobs 0 | tail -n 1)

# The message we received will have the job uuid
echo "Running job $jobid"

# Get the git revision we're supposed to check out
rev=$(redis-cli hget "${jobid}" "rev")
echo Checking out revision "$rev"

# Get the git ref
ref=$(redis-cli hget "${jobid}" "ref")

# Prepare the repository (hardcoded path) by getting that commit
cd test || exit; git fetch && git reset --hard "$rev";

# Actually runs the job and saves the output
if ! output=$(./ci.sh "$ref" 2>&1);
then
    status="failed";
else
    status="success";
fi;

# Update the result status
redis-cli hset "${jobid}" "status" $status;

# Update the job output
redis-cli hset "${jobid}" "output" "$output";

echo "Job ${jobid} done"

done
