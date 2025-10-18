#!/usr/bin/env -S uv run
"""Build script for bandageman.com using Jinja2 templates."""

import argparse
from pathlib import Path

import yaml
from jinja2 import Environment, FileSystemLoader


def load_config():
    """Load site configuration from YAML."""
    config_path = Path("config/site.yaml")
    with open(config_path) as f:
        return yaml.safe_load(f)


def add_game(slug: str):
    """Add a new game to the config file."""
    config_path = Path("config/site.yaml")

    with open(config_path) as f:
        config = yaml.safe_load(f)

    for game in config.get("games", []):
        if game["slug"] == slug:
            print(f"⚠️  Game '{slug}' already exists in config/site.yaml")
            return

    title = " ".join(word.capitalize() for word in slug.split("-"))

    new_game = {
        "slug": slug,
        "title": title,
        "description": f"Play {title}, a PICO-8 game by Bandageman Studios",
        "keywords": f"{title}, PICO-8, indie game, retro game, bandageman studios",
    }

    if "games" not in config:
        config["games"] = []
    config["games"].append(new_game)

    with open(config_path, "w") as f:
        yaml.dump(config, f, default_flow_style=False, sort_keys=False)

    print(f"✓ Added '{slug}' to config/site.yaml")
    print(f"  Title: {title}")
    print("\nEdit config/site.yaml to customize the title and description if needed.")


def build_homepage(env, config, output_dir):
    """Build the homepage from template."""
    template = env.get_template("index.html.j2")

    homepage = config["homepage"]
    site = config["site"]

    html = template.render(
        page_title=homepage["title"],
        description=homepage["description"],
        keywords=homepage["keywords"],
        og_url=site["base_url"] + "/",
        og_image=homepage["og_image"],
        games=config["games"],
        coming_soon_slots=homepage["coming_soon_slots"],
    )

    output_path = output_dir / "index.html"
    if not html.endswith("\n"):
        html += "\n"
    output_path.write_text(html)
    print(f"✓ Built {output_path}")


def build_all(output_dir):
    """Build all pages."""
    env = Environment(
        loader=FileSystemLoader("templates"),
        autoescape=True,
        trim_blocks=True,
        lstrip_blocks=True,
    )

    config = load_config()

    output_dir.mkdir(parents=True, exist_ok=True)

    build_homepage(env, config, output_dir)


def main():
    parser = argparse.ArgumentParser(description="Build bandageman.com")
    parser.add_argument(
        "--output",
        "-o",
        type=Path,
        default=Path("site"),
        help="Output directory (default: site)",
    )
    parser.add_argument(
        "--add-game",
        type=str,
        metavar="SLUG",
        help="Add a new game to config/site.yaml",
    )

    args = parser.parse_args()

    if args.add_game:
        add_game(args.add_game)
    else:
        build_all(args.output)
        print("\n✨ Build complete!")


if __name__ == "__main__":
    main()
