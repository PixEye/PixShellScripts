#!/bin/bash

counter=0
global=toto

function testIt {
	i=0
	let counter=$counter+1
	echo "testIt (call #$counter) $*: global='$global' & i=$i"
	let i=$i+1
	return $counter
}

testIt with this
echo ret=$?

global=titi

testIt with that
echo ret=$?
