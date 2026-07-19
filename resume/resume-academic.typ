// Academic CV for Fachry Dennis Heraldi.
// Targeted at AI/ML graduate program applications.
// Renderer only; all content lives in ../_data/*.yml.
// Compile from the repo root:  typst compile --root . resume/resume-academic.typ "resume/academic/CV - Fachry Dennis Heraldi.pdf"

#import "_template.typ": *

#let profile = yaml("../_data/profile.yml")
#let experience = yaml("../_data/experience.yml")
#let education = yaml("../_data/education.yml")
#let skills = yaml("../_data/skills.yml")
#let awards = yaml("../_data/awards.yml")
#let teaching = yaml("../_data/teaching.yml")

#show: apply-page-setup.with(
  title: profile.name + " Academic CV",
  author: profile.name,
  margin: 0.5in,
  leading: 0.35em,
  spacing: 0.5em,
  size: 10.5pt,
)

// Header uses the academic-flavored summary.
#resume-header(profile, profile.at("summary_academic", default: profile.summary))

// Education leads on academic CVs.
#education-section(education)

// Publications & Awards. Filters entries to those tagged audience: "academic"
// or "both" (e.g. ICAICTA paper + RubBot competition win).
#awards-section(awards, audience: "academic")

// Teaching Experience: academic service, slotted between research output and
// industry experience.
#teaching-section(teaching)

// Work Experience appears next; audience filter hides Synpulse on this CV
// (it's tagged audience: "swe") and the audience: "academic" path on each
// remaining entry merges in any academic-flavored bullets.
#work-experience(experience, audience: "academic")

#skills-section(skills)
