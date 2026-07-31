# Dennis Heraldi - Personal Portfolio

My personal portfolio and blog built with [Jekyll](https://jekyllrb.com) and [Tailwind CSS](https://tailwindcss.com).

## Features

- Dark, minimal design, responsive down to mobile
- Blog written in Markdown
- **Two resumes** (Software Engineering + Academic CV) generated from a shared YAML source of truth, auto-compiled to PDF via Typst
- Static site hosted on GitHub Pages

## Deployment

This site auto-deploys to GitHub Pages via GitHub Actions. Push to `main` and the workflow builds and publishes it.

### Setup GitHub Pages

1. Go to repository **Settings** > **Pages**
2. Under "Build and deployment", select **GitHub Actions** as the source
3. Push to `main` - the workflow will automatically build and deploy

## Resume / CV

Two resume variants are generated from a single YAML source of truth:

- **Software Engineering resume**: `resume/swe/CV - Fachry Dennis Heraldi.pdf` (also published at `resume/resume.pdf` for backwards compatibility).
- **Academic CV**: `resume/academic/CV - Fachry Dennis Heraldi.pdf`. Targeted at AI/ML graduate program applications; leads with Education and Publications & Awards.

### How it works

Resume content lives in `_data/*.yml`. The Typst templates only render; they don't store content. The homepage keeps shorter experience copy in a separate file so it does not duplicate the CV.

### Files

```
_data/
├── profile.yml       # Website positioning, resume summaries, contact, links
├── experience.yml    # Detailed work experience for both resumes
├── website_experience.yml # Short experience summaries for the homepage
├── selected_projects.yml  # Projects grouped under homepage experience
├── education.yml     # Education
├── skills.yml        # Technical skills for both resumes
└── awards.yml        # Publications & Awards (academic CV only)

resume/
├── _template.typ            # Shared layout primitives + markdown helper
├── resume-swe.typ           # SWE resume renderer
├── resume-academic.typ      # Academic CV renderer
├── swe/
│   └── CV - Fachry Dennis Heraldi.pdf       # Generated SWE PDF (auto-built)
├── academic/
│   └── CV - Fachry Dennis Heraldi.pdf       # Generated academic CV (auto-built)
└── resume.pdf               # Backwards-compat alias of the SWE PDF
```

### Bullet formatting

Resume highlight strings in `experience.yml` accept basic Markdown:

- `**text**` for **bold**.
- `*text*` for *italic*.

### Per-audience bullets

Inside an `experience` entry you can split bullets:

```yaml
highlights:           # always shown
  - "Always-relevant bullet"
highlights_swe:       # appended on the SWE resume only
  - "Industry-flavored bullet"
highlights_academic:  # appended on the academic CV only
  - "Research-flavored bullet"
```

### Updating your resume

1. Edit the relevant `_data/*.yml` file.
2. Push to `main`.
3. GitHub Actions compiles both PDFs and rebuilds the site.
4. Both `/resume/swe/CV - Fachry Dennis Heraldi.pdf` and `/resume/academic/CV - Fachry Dennis Heraldi.pdf` are updated, and the `/cv` page (which has SWE/Academic tabs) reflects the change.

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

# Compile both resumes (--root . lets the templates read ../_data/*.yml)
mkdir -p resume/swe resume/academic
typst compile --root . resume/resume-swe.typ "resume/swe/CV - Fachry Dennis Heraldi.pdf"
typst compile --root . resume/resume-academic.typ "resume/academic/CV - Fachry Dennis Heraldi.pdf"
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
│   ├── _template.typ          # Shared Typst primitives
│   ├── resume-swe.typ         # SWE resume source
│   ├── resume-academic.typ    # Academic CV source
│   ├── swe/                   # Generated SWE PDF (CV - Fachry Dennis Heraldi.pdf)
│   ├── academic/              # Generated academic CV (CV - Fachry Dennis Heraldi.pdf)
│   └── resume.pdf             # Alias of the SWE PDF (backwards-compat)
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
