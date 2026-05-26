// Academic CV for Fachry Dennis Heraldi.
// Targeted at AI/ML graduate program applications.
// Renderer only; all content lives in ../_data/*.yml.
// Compile from the repo root:  typst compile --root . resume/resume-academic.typ resume/resume-academic.pdf

#import "_template.typ": *

#let profile = yaml("../_data/profile.yml")
#let experience = yaml("../_data/experience.yml")
#let education = yaml("../_data/education.yml")
#let skills = yaml("../_data/skills.yml")
#let awards = yaml("../_data/awards.yml")

#show: apply-page-setup.with(
  title: profile.name + " Academic CV",
  author: profile.name,
  margin: 0.3in,
  leading: 0.3em,
  spacing: 0.45em,
  size: 9.5pt,
)

// Header uses the academic-flavored summary.
#resume-header(profile, profile.at("summary_academic", default: profile.summary))

// Education leads on academic CVs.
#education-section(education)

// Publications & Awards is the second section. It surfaces the ICAICTA paper.
#awards-section(awards)

// Work Experience appears next; uses audience: "academic" so any
// academic-flavored bullets in experience.yml get appended.
#work-experience(experience, audience: "academic")

#skills-section(skills)
