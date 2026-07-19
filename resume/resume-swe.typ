// Software-engineering resume for Fachry Dennis Heraldi.
// Renderer only; all content lives in ../_data/*.yml.
// Compile from the repo root:  typst compile --root . resume/resume-swe.typ "resume/swe/CV - Fachry Dennis Heraldi.pdf"

#import "_template.typ": *

#let profile = yaml("../_data/profile.yml")
#let experience = yaml("../_data/experience.yml")
#let education = yaml("../_data/education.yml")
#let skills = yaml("../_data/skills.yml")
#let awards = yaml("../_data/awards.yml")

#show: apply-page-setup.with(
  title: profile.name + " Resume",
  author: profile.name,
  margin: 0.5in,
  leading: 0.35em,
  spacing: 0.5em,
  size: 10.5pt,
)

// Header uses the default `summary` (SWE-flavored).
#resume-header(profile, profile.summary)

// Sections ordered for software-engineering readers.
#work-experience(experience, audience: "swe")

#education-section(education, show-coursework: false)

// Awards section uses a more SWE-friendly title and is filtered to entries
// tagged audience: "swe" or "both" (the academic-only RubBot entry is hidden).
#awards-section(awards, audience: "swe", title: "Awards & Recognition")

#skills-section(skills)
