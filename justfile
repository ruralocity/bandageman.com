# List available recipes
list:
  @just --list

# Run server locally
run:
  python3 -m http.server site --directory site
