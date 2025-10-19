#!/usr/bin/env -S uv run
"""Build script for bandageman.com using Jinja2 templates."""

import argparse
import re
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


def inject_game_metadata(game_dir: Path, game_config: dict, base_url: str):
    """Inject metadata and tracking into a game's HTML file."""
    html_path = game_dir / "index.html"

    if not html_path.exists():
        print(f"⚠️  Skipping {game_dir.name}: index.html not found")
        return

    html = html_path.read_text()

    # Check if already has metadata (check for og:title)
    if 'property="og:title"' in html:
        print(f"✓ {game_dir.name}/index.html already has metadata")
        return

    slug = game_config["slug"]
    title = game_config["title"]
    description = game_config["description"]
    keywords = game_config["keywords"]
    game_url = f"{base_url}/{slug}/"

    # Build metadata HTML
    metadata = f'''<meta charset="UTF-8">
<title>{title} - Bandageman Studios</title>

<!-- SEO Meta Tags -->
<meta name="description" content="{description}">
<meta name="keywords" content="{keywords}">
<meta name="author" content="Bandageman Studios">

<!-- Open Graph / Facebook -->
<meta property="og:type" content="website">
<meta property="og:url" content="{game_url}">
<meta property="og:title" content="{title} - Bandageman Studios">
<meta property="og:description" content="{description}">
<meta property="og:image" content="{base_url}/{slug}/{slug}-splash.png">

<!-- Twitter -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:url" content="{game_url}">
<meta name="twitter:title" content="{title} - Bandageman Studios">
<meta name="twitter:description" content="{description}">
<meta name="twitter:image" content="{base_url}/{slug}/{slug}-splash.png">

<!-- Theme Color -->
<meta name="theme-color" content="#222222">

<!-- Canonical URL -->
<link rel="canonical" href="{game_url}">

<link rel="icon" href="/images/favicon.ico" type="image/x-icon">
<script defer data-domain="bandageman.com" src="https://plausible.io/js/script.js"></script>
'''

    # Replace the existing title and viewport tags with our metadata
    # PICO-8 HTML typically has <title>PICO-8 Cartridge</title> and a viewport tag
    html = re.sub(
        r'<title>.*?</title>\s*<meta name="viewport"[^>]*>',
        metadata + '<meta name="viewport" content="width=device-width, user-scalable=no">',
        html,
        flags=re.DOTALL
    )

    # Add footer before closing body tag if not present
    if 'bandageman-transparent.png' not in html:
        footer = '''
<style>
.footer-logo-link:hover img {
	animation: pop 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
}
@keyframes pop {
	0% { transform: scale(1); }
	50% { transform: scale(1.2); }
	100% { transform: scale(1); }
}
</style>

<div style="text-align: center; margin-top: 40px; padding-bottom: 20px;">
	<a href="/" class="footer-logo-link">
		<img src="/images/bandageman-transparent.png" alt="Bandageman Studios" style="max-width: 50px; height: auto;">
	</a>
</div>
'''
        html = html.replace('</body>', footer + '</body>')

    # Ensure trailing newline
    if not html.endswith('\n'):
        html += '\n'

    html_path.write_text(html)
    print(f"✓ Injected metadata into {game_dir.name}/index.html")


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

    # Build homepage
    build_homepage(env, config, output_dir)

    # Inject metadata into game pages
    base_url = config["site"]["base_url"]
    for game in config.get("games", []):
        game_dir = output_dir / game["slug"]
        if game_dir.exists():
            inject_game_metadata(game_dir, game, base_url)


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
