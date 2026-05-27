// Software-engineering resume for Fachry Dennis Heraldi.
// Renderer only; all content lives in ../_data/*.yml.
// Compile from the repo root:  typst compile --root . resume/resume-swe.typ resume/resume-swe.pdf

#import "_template.typ": *

#let profile = yaml("../_data/profile.yml")
#let experience = yaml("../_data/experience.yml")
#let education = yaml("../_data/education.yml")
#let skills = yaml("../_data/skills.yml")
#let awards = yaml("../_data/awards.yml")

#show: apply-page-setup.with(
  title: profile.name + " Resume",
  author: profile.name,
  margin: 0.3in,
  leading: 0.3em,
  spacing: 0.45em,
  size: 9.5pt,
)

// Header uses the default `summary` (SWE-flavored).
#resume-header(profile, profile.summary)

// Sections ordered for software-engineering readers.
#work-experience(experience, audience: "swe")

#education-section(education)

// Awards section uses a more SWE-friendly title and is filtered to entries
// tagged audience: "swe" or "both" (the academic-only RubBot entry is hidden).
#awards-section(awards, audience: "swe", title: "Awards & Recognition")

#skills-section(skills)
