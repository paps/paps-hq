#!/usr/bin/env bash

supervisor --no-restart-on error -w app -e 'node|js|json|coffee' -i 'app/client,app/public' 'app/app.coffee'
