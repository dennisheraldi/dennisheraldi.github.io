// Software-engineering resume for Fachry Dennis Heraldi.
// Renderer only; all content lives in ../_data/*.yml.
// Compile from the repo root:  typst compile --root . resume/resume-swe.typ resume/resume-swe.pdf

#import "_template.typ": *

#let profile = yaml("../_data/profile.yml")
#let experience = yaml("../_data/experience.yml")
#let education = yaml("../_data/education.yml")
#let skills = yaml("../_data/skills.yml")

#setup-page(profile.name + " Resume", profile.name)

// Header uses the default `summary` (SWE-flavored).
#resume-header(profile, profile.summary)

// Sections ordered for software-engineering readers.
#work-experience(experience, audience: "swe")

#education-section(education)

#skills-section(skills)
