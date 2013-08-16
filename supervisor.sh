#!/usr/bin/env bash

supervisor --no-restart-on error -w app -e 'node|js|json|coffee' app/app.coffee
