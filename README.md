# Dennis Heraldi - Personal Portfolio

My personal portfolio and blog built with [Jekyll](https://jekyllrb.com) and [Tailwind CSS](https://tailwindcss.com).

## Features

- Clean, minimal design with dark/light mode
- Responsive layout for all devices
- Blog with markdown support
- **Resume/CV** in Typst format with auto-compilation to PDF
- Fast static site generation
- GitHub Pages compatible

## Deployment

This site auto-deploys to GitHub Pages via GitHub Actions. Just push to the `main` branch!

### Setup GitHub Pages

1. Go to repository **Settings** > **Pages**
2. Under "Build and deployment", select **GitHub Actions** as the source
3. Push to `main` - the workflow will automatically build and deploy

## Resume / CV

The resume is written in [Typst](https://typst.app) and automatically compiled to PDF on every push.

### Files

- `resume/resume.typ` - Typst source file (edit this)
- `resume/resume.pdf` - Generated PDF (auto-built)
- `resume/resume-thumb.png` - Generated thumbnail (auto-built)

### Updating your resume

1. Edit `resume/resume.typ`
2. Push to `main`
3. GitHub Actions will compile it to PDF and generate a thumbnail
4. The CV page will show the updated resume

## Local Development

### Prerequisites

- Ruby 3.0+ (install via [rbenv](https://github.com/rbenv/rbenv) or [asdf](https://asdf-vm.com/))
- Bundler
- Node.js 18+
- (Optional) [Typst](https://typst.app) for local resume compilation

### Setup

```bash
# Install Ruby dependencies
bundle install

# Install Node dependencies
npm install

# Build Tailwind CSS
npm run css:build

# Start Jekyll server
bundle exec jekyll serve --livereload
```

The site will be available at `http://localhost:4000`.

### Watch Mode (for development)

In separate terminals:

```bash
# Terminal 1: Watch Tailwind CSS
npm run css:watch

# Terminal 2: Run Jekyll
bundle exec jekyll serve --livereload
```

### Local Resume Compilation (optional)

```bash
# Install Typst (macOS)
brew install typst

# Compile resume
typst compile resume/resume.typ resume/resume.pdf
```

## Adding Blog Posts

Create a new file in `_posts/` with the naming format `YYYY-MM-DD-title.md`:

```markdown
---
layout: post
title: 'Your Post Title'
description: 'A brief description of your post'
date: 2024-12-06
tags: [tag1, tag2]
---

Your content here...
```

## Project Structure

```
├── _config.yml          # Jekyll configuration
├── _data/               # Data files (experience, skills)
├── _includes/           # Reusable components (header, footer)
├── _layouts/            # Page layouts
├── _posts/              # Blog posts
├── assets/
│   ├── css/             # Tailwind CSS
│   └── js/              # JavaScript
├── public/              # Static assets (images, favicon)
├── resume/
│   ├── resume.typ       # Typst source
│   ├── resume.pdf       # Generated PDF
│   └── resume-thumb.png # Generated thumbnail
├── index.html           # Homepage
├── blog.html            # Blog index
├── cv.html              # CV/Resume page
├── Gemfile              # Ruby dependencies
├── package.json         # Node dependencies
└── tailwind.config.js   # Tailwind configuration
```

## Tech Stack

- [Jekyll](https://jekyllrb.com) - Static site generator
- [Tailwind CSS](https://tailwindcss.com) - Styling
- [Typst](https://typst.app) - Resume typesetting
- [Liquid](https://shopify.github.io/liquid/) - Templating

## License

MIT
