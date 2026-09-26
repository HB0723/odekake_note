#!/usr/bin/env bash
# Build script for Render
set -o errexit

bundle install
bin/rails assets:precompile
bin/rails assets:clean
bin/rails db:migrate
