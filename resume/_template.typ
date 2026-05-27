// Shared layout primitives used by resume-swe.typ and resume-academic.typ.
// Imported via `#import "_template.typ": *`.

// Common colors
#let muted = rgb("#64748b")

// --- Minimal Markdown -> Typst content ---------------------------------------
// Supports **bold** and *italic*. Works by splitting on the delimiters and
// alternating styles; safer than eval() because YAML bullets contain `%`,
// `#`, `@`, etc. which Typst's parser would otherwise interpret.

#let render-italic(s) = {
  let parts = s.split("*")
  let out = []
  for i in range(parts.len()) {
    let p = parts.at(i)
    out += if calc.rem(i, 2) == 0 { [#p] } else { emph(p) }
  }
  out
}

#let md(s) = {
  let parts = s.split("**")
  let out = []
  for i in range(parts.len()) {
    let p = parts.at(i)
    out += if calc.rem(i, 2) == 0 { render-italic(p) } else { strong(p) }
  }
  out
}

// --- Layout primitives -------------------------------------------------------

#let section-title(title) = {
  v(0.3em)
  text(weight: "bold", title)
  v(-0.3em)
  line(length: 100%, stroke: 0.6pt)
  v(0.2em)
}

#let entry-header(title, location) = {
  grid(
    columns: (1fr, auto),
    text(weight: "bold", title),
    text(location),
  )
}

#let entry-subheader(role, period) = {
  grid(
    columns: (1fr, auto),
    text(style: "italic", role),
    text(style: "italic", period),
  )
}

#let bullet-item(content) = {
  grid(
    columns: (1em, 1fr),
    gutter: 0.3em,
    align(center + horizon, text(size: 0.6em, "•")),
    content,
  )
}

// --- Page setup helper -------------------------------------------------------
// Returns a `show` rule body that applies typography settings to the whole
// document. Use it like:
//
//   #show: apply-page-setup.with(title: "...", author: "...")
//
// This pattern is required because `set` rules inside a regular function only
// affect content returned by that function. By wrapping the body in a show rule,
// the settings apply to the entire document.

#let apply-page-setup(
  body,
  title: "",
  author: "",
  margin: 0.4in,
  leading: 0.4em,
  spacing: 0.55em,
  size: 10pt,
) = {
  set document(title: title, author: author)
  set page(paper: "a4", margin: (x: margin, y: margin))
  set text(font: "Arial", size: size, hyphenate: false)
  set par(justify: true, leading: leading, spacing: spacing)
  body
}

// --- Header block (name + summary on left; contact on right) ----------------

#let resume-header(profile, summary) = {
  grid(
    columns: (60%, 40%),
    gutter: 1em,
    [
      #text(size: 18pt, weight: "bold")[#profile.name]

      #text(size: 9pt)[#summary]
    ],
    align(right)[
      #text(size: 9pt)[
        #profile.location | #profile.phone \
        #link("mailto:" + profile.email)[#profile.email]
        #for l in profile.links [
           \ #link(l.url)[#l.short]
        ]
      ]
    ],
  )
  v(0.2em)
}

// --- Section: Work Experience -----------------------------------------------
// `audience` is "swe" or "academic"; selects which extra highlights to merge in.

#let work-experience(experience, audience: "swe") = {
  // Filter entries by `audience` field: "both" (default) shows on both resumes,
  // "swe" or "academic" restricts to a single audience.
  let visible = experience.filter(j => {
    let aud = j.at("audience", default: "both")
    aud == "both" or aud == audience
  })
  if visible.len() == 0 { return }

  section-title("Work Experience")
  for (i, job) in visible.enumerate() {
    let same-company-as-prev = i > 0 and visible.at(i - 1).company == job.company
    if i > 0 { v(if same-company-as-prev { 0.1em } else { 0.3em }) }

    // Suppress company header + description on consecutive same-company entries
    // (e.g. promotions) so the role row stacks cleanly under the company.
    if not same-company-as-prev {
      entry-header(job.company, job.at("location_short", default: job.location))
    }
    entry-subheader(job.role, job.at("period_full", default: job.period))
    if not same-company-as-prev and "description" in job and job.description != none {
      text(size: 9pt, fill: muted, job.description)
    }
    v(0.1em)

    // Combine shared `highlights` with audience-specific extras (preserving order).
    let bullets = job.at("highlights", default: ())
    let extras = if audience == "academic" {
      job.at("highlights_academic", default: ())
    } else {
      job.at("highlights_swe", default: ())
    }
    for h in bullets { bullet-item(md(h)) }
    for h in extras { bullet-item(md(h)) }
  }
}

// --- Section: Education ------------------------------------------------------

#let education-section(education, show-coursework: true) = {
  section-title("Education")
  for (i, ed) in education.enumerate() {
    if i > 0 { v(0.2em) }
    entry-header(ed.school, ed.at("period_full", default: ed.period))
    entry-subheader(ed.degree, "CGPA: " + ed.gpa)
    if show-coursework and "coursework" in ed and ed.coursework != none {
      v(0.1em)
      bullet-item(md("**Relevant Coursework**: " + ed.coursework.join(", ")))
    }
    if "thesis" in ed and ed.thesis != none {
      v(0.1em)
      bullet-item(md("**Thesis**: " + ed.thesis))
    }
  }
}

// --- Section: Technical Skills ----------------------------------------------

#let skills-section(skills, only: none) = {
  section-title("Technical Skills")
  for cat in skills {
    let allow = if only == none { true } else { cat.at("audience", default: "both") == "both" or cat.at("audience", default: "both") == only }
    if allow {
      bullet-item(md("**" + cat.title + "**: " + cat.skills.join(", ")))
    }
  }
}

// --- Section: Teaching Experience -------------------------------------------

#let teaching-section(teaching, title: "Teaching Experience") = {
  if teaching.len() == 0 { return }
  section-title(title)
  for (i, t) in teaching.enumerate() {
    if i > 0 { v(0.2em) }
    entry-header(t.institution, t.at("location", default: ""))
    entry-subheader(t.role, t.at("period_full", default: t.period))
    v(0.1em)
    for h in t.at("highlights", default: ()) {
      bullet-item(md(h))
    }
  }
}

// --- Section: Publications & Awards (academic only) -------------------------

#let awards-section(awards, audience: "academic", title: "Publications & Awards") = {
  // Filter entries by their `audience` field: "both" (default) shows on both,
  // "swe" or "academic" restricts to just one.
  let visible = awards.filter(a => {
    let aud = a.at("audience", default: "both")
    aud == "both" or aud == audience
  })
  if visible.len() == 0 { return }

  section-title(title)
  for (i, a) in visible.enumerate() {
    if i > 0 { v(0.2em) }
    entry-header(a.title, a.at("location", default: ""))
    entry-subheader(a.at("venue", default: ""), a.at("date", default: ""))
    if "authors" in a and a.authors != none {
      text(size: 9pt, fill: muted, a.authors)
    }
    v(0.1em)
    for h in a.at("highlights", default: ()) {
      bullet-item(md(h))
    }
  }
}
