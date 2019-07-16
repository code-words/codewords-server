# Codewords Server [![Build Status](https://travis-ci.com/code-words/codewords-server.svg?branch=dev)](https://travis-ci.com/code-words/codewords-server)

This is the server side of the Codewords game. It manages game state and handles turn logic, however it does not have a built-in front-end. You will also need the Codewords UI available within this organization.

### Requirements

- Ruby 2.6.3
- Rails 5.2.3
- This server

### Setup

01. Clone this repository and run `bundle install`.
02. Prepare database with `rails db:create`
03. Migrate with `rails db:migrate`
04. Start the server with `rails s`


### Schema

[![Database Schema Diagram](schema.png)](https://dbdiagram.io/d/5d28ffa3ced98361d6dc9ccb)
